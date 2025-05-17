resource "google_project" "this" {
  project_id      = "prj-tpcds-${random_string.this.result}"
  name            = "prj-tpcds-${random_string.this.result}"
  org_id          = var.org_id
  folder_id       = var.folder_id
  billing_account = var.billing_account_id

  labels = {
    environment = "data-platform"
    managed-by  = "terraform"
  }

  auto_create_network = false
}

resource "google_project_service" "bigquery_api" {
  project                    = google_project.this.project_id
  service                    = "bigquery.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_project_service" "compute_api" {
  project                    = google_project.this.project_id
  service                    = "compute.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_project_service" "storage_api" {
  project                    = google_project.this.project_id
  service                    = "storage.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_project_service" "datalineage_api" {
  project                    = google_project.this.project_id
  service                    = "datalineage.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_bigquery_dataset" "this" {
  for_each = toset(var.bq_dataset_names)

  project    = google_project.this.project_id
  dataset_id = each.key
  location   = var.region

  description = "Dataset ${each.key} managed by Terraform"

  labels = {
    environment = "data-platform"
    managed-by  = "terraform"
  }

  depends_on = [
    google_project_service.bigquery_api
  ]
}

resource "google_compute_network" "vpc_network" {
  project                 = google_project.this.project_id
  name                    = "terraform-network"
  auto_create_subnetworks = false
  depends_on              = [google_project_service.compute_api]
}

resource "google_compute_subnetwork" "subnet" {
  project       = google_project.this.project_id
  name          = "terraform-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

resource "google_service_account" "vm_service_account" {
  project      = google_project.this.project_id
  account_id   = "vm-service-account"
  display_name = "Service Account for VM Instance"
}

resource "google_compute_instance" "vm_instance" {
  project      = google_project.this.project_id
  name         = "vm-tpcds-${random_string.this.result}"
  machine_type = "n2-standard-2"
  zone         = "${var.region}-a"

  tags = ["web", "terraform"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
      size  = 20
      type  = "pd-standard"
      labels = {
        environment = "data-platform"
      }
    }
  }

  scratch_disk {
    interface = "NVME"
  }

  network_interface {
    network            = google_compute_network.vpc_network.name
    subnetwork         = google_compute_subnetwork.subnet.name
    subnetwork_project = google_project.this.project_id

    access_config {}
  }

  metadata = {
    environment = "data-platform"
    managed-by  = "terraform"
  }

  metadata_startup_script = "echo 'Hello from Terraform' > /startup_log.txt"

  service_account {
    email  = google_service_account.vm_service_account.email
    scopes = ["cloud-platform"]
  }

  depends_on = [
    google_project_service.compute_api
  ]
}

resource "google_project_iam_binding" "vm_sa_binding" {
  project = google_project.this.project_id
  role    = "roles/compute.viewer"

  members = [
    "serviceAccount:${google_service_account.vm_service_account.email}",
  ]
}

resource "google_project_iam_binding" "vm_sa_binding_0" {
  project = google_project.this.project_id
  role    = "roles/storage.objectAdmin"

  members = [
    "serviceAccount:${google_service_account.vm_service_account.email}",
  ]
}

resource "google_project_iam_binding" "vm_sa_binding_1" {
  project = google_project.this.project_id
  role    = "roles/storage.admin"

  members = [
    "serviceAccount:${google_service_account.vm_service_account.email}",
  ]
}

resource "google_project_iam_binding" "vm_sa_binding_2" {
  project = google_project.this.project_id
  role    = "roles/serviceusage.serviceUsageConsumer"

  members = [
    "serviceAccount:${google_service_account.vm_service_account.email}",
  ]
}

resource "random_string" "this" {
  length  = 5
  special = false
  upper   = false
}

resource "google_storage_bucket" "default" {
  project       = google_project.this.project_id
  name          = "bkt-tpcds-${random_string.this.result}"
  location      = var.region
  force_destroy = true

  depends_on = [
    google_project_service.storage_api
  ]
}

resource "local_file" "tpc_ds_script" {
  content = templatefile("${path.module}/templates/tpc_ds.sh.tftpl", {
    project_id  = google_project.this.project_id
    bucket_name = google_storage_bucket.default.name
  })
  filename        = "${path.module}/templates/tpc_ds.tmp.sh"
  file_permission = "0755"
}

resource "local_file" "tpc_ds_script1" {
  content = templatefile("${path.module}/templates/tpc_ds_load_native_noauto.tftpl", {
    project_id  = google_project.this.project_id
    bucket_name = google_storage_bucket.default.name
    bigquery_dataset_id = [
      for dataset_id in var.bq_dataset_names : dataset_id
      if can(regex(".*tpcds.*", dataset_id))
    ][0]
  })
  filename        = "${path.module}/templates/tpc_ds_load_native_noauto.tmp.sh"
  file_permission = "0755"
}

resource "local_file" "tpc_ds_script2" {
  content = templatefile("${path.module}/templates/row_counts_1_gb_meta.tftpl", {
    project_id  = google_project.this.project_id
    bucket_name = google_storage_bucket.default.name
    bigquery_dataset_id = [
      for dataset_id in var.bq_dataset_names : dataset_id
      if can(regex(".*tpcds.*", dataset_id))
    ][0]
  })
  filename        = "${path.module}/templates/row_counts_1_gb_meta.tmp.sql"
  file_permission = "0755"
}

resource "local_file" "tpc_ds_script3" {
  content = templatefile("${path.module}/templates/row_counts_1_gb.tftpl", {
    project_id  = google_project.this.project_id
    bucket_name = google_storage_bucket.default.name
    bigquery_dataset_id = [
      for dataset_id in var.bq_dataset_names : dataset_id
      if can(regex(".*tpcds.*", dataset_id))
    ][0]
  })
  filename        = "${path.module}/templates/row_counts_1_gb.tmp.sql"
  file_permission = "0755"
}
