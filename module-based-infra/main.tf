# 1. Create the GCP Project using the Project Factory module
module "project_factory" {
  source  = "terraform-google-modules/project-factory/google"
  version = "18.0.0"

  name                        = var.gcp_project_id # This becomes the project_id
  random_project_id           = false              # We are providing a specific ID
  org_id                      = var.org_id
  folder_id                   = var.folder_id
  billing_account             = var.billing_account_id
  default_service_account     = "deprivileged" # "keep", "disable", "delete", "deprivileged"
  disable_services_on_destroy = false

  activate_apis = [
    "bigquery.googleapis.com",
    # Add other APIs if needed, e.g., "compute.googleapis.com"
  ]

  labels = {
    environment = "data-platform"
    managed-by  = "terraform-module"
  }

  # It's good practice to explicitly disable the default network if not needed
  auto_create_network = false
}

# 2. Create BigQuery Datasets using the BigQuery module
module "bigquery_datasets" {
  source  = "terraform-google-modules/bigquery/google"
  version = "10.1.0"

  project_id = module.project_factory.project_id # Use the output from the project factory
  location   = var.default_bq_location           # Default location for all datasets

  # Define datasets. The module expects a map of dataset objects.
  # We can construct this dynamically.
  datasets = {
    for ds_name in var.dataset_names : ds_name => {
      dataset_id    = ds_name
      friendly_name = ds_name
      description   = "Dataset ${ds_name} managed by Terraform BigQuery module"
      # location can be overridden per dataset if needed, otherwise uses module-level location
      # location                 = "EU"
      default_table_expiration_ms = null # No default expiration
      labels = {
        environment = "data-platform"
        managed-by  = "terraform-module"
      }
    }
  }

  # The BigQuery module handles dependencies internally if APIs are enabled by project_factory
  # or if you ensure APIs are active before this module runs.
}
