output "project_id" {
  description = "The ID of the created GCP project."
  value       = module.project_factory.project_id
}

output "project_number" {
  description = "The number of the created GCP project."
  value       = module.project_factory.project_number
}

output "bigquery_dataset_ids" {
  description = "A list of created BigQuery dataset IDs."
  value       = module.bigquery_datasets.dataset_ids
}

output "bigquery_datasets_map" {
  description = "A map of created BigQuery datasets with their full details."
  value       = module.bigquery_datasets.datasets
  sensitive   = true # The module output might contain sensitive defaults
}
