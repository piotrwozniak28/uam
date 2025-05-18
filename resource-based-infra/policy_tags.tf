resource "google_data_catalog_taxonomy" "this" {
  project                = google_project.this.project_id
  region                 = var.region
  display_name           = "tax-tpcds-${random_string.this.result}"
  description            = "A collection of policy tags"
  activated_policy_types = ["FINE_GRAINED_ACCESS_CONTROL"]
}

resource "google_data_catalog_policy_tag" "this" {
  taxonomy     = google_data_catalog_taxonomy.this.id
  display_name = "PII_Data"
  description  = "Policy tag for Personally Identifiable Information (PII) that requires controlled access"
}

# resource "google_data_catalog_policy_tag" "child_policy" {
#   taxonomy          = google_data_catalog_taxonomy.this.id
#   display_name      = "ssn"
#   description       = "A hash of the users ssn"
#   parent_policy_tag = google_data_catalog_policy_tag.parent_policy.id
# }

# resource "google_data_catalog_policy_tag" "child_policy2" {
#   taxonomy          = google_data_catalog_taxonomy.this.id
#   display_name      = "dob"
#   description       = "The users date of birth"
#   parent_policy_tag = google_data_catalog_policy_tag.parent_policy.id
#   // depends_on to avoid concurrent delete issues
#   depends_on = [google_data_catalog_policy_tag.child_policy]
# }

# Grant fine-grained reader access to the user on the PII policy tag
# resource "google_data_catalog_policy_tag_iam_member" "pii_reader" {
#   policy_tag = google_data_catalog_policy_tag.this.id
#   role       = "roles/datacatalog.categoryFineGrainedReader"
#   member     = "user:gftdummyuser100@customcloudsolutions.pl"
# }

output "google_data_catalog_taxonomy" {
  value = google_data_catalog_taxonomy.this
}

output "google_data_catalog_policy_tag_pii" {
  value       = google_data_catalog_policy_tag.this
  description = "Policy tag for PII data that requires controlled access"
}
# output "google_data_catalog_policy_tag_child_policy" {
#   value = google_data_catalog_policy_tag.child_policy
# }
# output "google_data_catalog_policy_tag_child_policy2" {
#   value = google_data_catalog_policy_tag.child_policy2
# }

resource "google_bigquery_datapolicy_data_policy" "data_policy" {
  location         = var.region
  data_policy_id   = "bq_data_policy_pii"
  policy_tag       = google_data_catalog_policy_tag.this.id
  data_policy_type = "DATA_MASKING_POLICY"
  data_masking_policy {
    predefined_expression = "SHA256"
  }
}

output "z_helper_urls" {
  value = [
    "https://console.cloud.google.com/bigquery/policy-tags/locations/${var.region}/taxonomies/${basename(google_data_catalog_taxonomy.this.id)};container=${google_project.this.project_id}",
  ]
}
