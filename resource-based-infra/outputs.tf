output "project_id" {
  description = "The ID of the created GCP project."
  value       = var.project_id # This will be the same as input for the resource version
  # For the module version, we'll override this in its specific outputs.tf
}

output "bigquery_dataset_ids" {
  description = "A list of created BigQuery dataset IDs."
  value       = null # This will be populated by each version's main.tf or specific outputs.tf
}
