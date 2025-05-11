# 1. Create the GCP Project
resource "google_project" "this" {
  project_id      = var.gcp_project_id
  name            = var.gcp_project_id # Often the same as project_id
  org_id          = var.org_id         # Required if not using folder_id
  folder_id       = var.folder_id      # Alternative to org_id
  billing_account = var.billing_account_id

  labels = {
    environment = "data-platform"
    managed-by  = "terraform"
  }

  # It's good practice to explicitly disable the default network if not needed
  auto_create_network = false

  # Prevents accidental deletion of the project via Terraform.
  # Set to false if you want Terraform to be able to delete the project.
  skip_delete = true
}

# 2. Enable necessary APIs on the project
# BigQuery API is essential for creating datasets
resource "google_project_service" "bigquery_api" {
  project                    = google_project.this.project_id
  service                    = "bigquery.googleapis.com"
  disable_dependent_services = false # Keep related services if any
  disable_on_destroy         = false # Allows Terraform to disable the API on destroy if desired
}

# 3. Create BigQuery Datasets
resource "google_bigquery_dataset" "this" {
  for_each = toset(var.dataset_names) # Use a set to iterate over unique dataset names

  project    = google_project.this.project_id
  dataset_id = each.key
  location   = var.default_bq_location

  friendly_name = each.key
  description   = "Dataset ${each.key} managed by Terraform"

  labels = {
    environment = "data-platform"
    managed-by  = "terraform"
  }

  # Ensure BigQuery API is enabled before trying to create datasets
  depends_on = [
    google_project_service.bigquery_api
  ]
}
