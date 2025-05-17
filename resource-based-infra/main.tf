resource "google_project" "this" {
  project_id      = var.project_id
  name            = var.project_id
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

resource "google_bigquery_dataset" "this" {
  for_each = toset(var.bq_dataset_names)

  project    = google_project.this.project_id
  dataset_id = each.key
  location   = var.region

  # friendly_name = each.key
  description = "Dataset ${each.key} managed by Terraform"

  labels = {
    environment = "data-platform"
    managed-by  = "terraform"
  }

  depends_on = [
    google_project_service.bigquery_api
  ]
}
