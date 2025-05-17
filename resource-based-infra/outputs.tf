output "project_id" {
  description = "The ID of the created GCP project."
  value       = "prj-tpcds-${random_string.this.result}"
}

output "bigquery_dataset_ids" {
  description = "A list of created BigQuery dataset IDs."
  value       = [for k in google_bigquery_dataset.this : k.dataset_id]
}
