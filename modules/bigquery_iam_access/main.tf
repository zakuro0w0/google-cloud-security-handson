data "google_project" "current" {}

resource "google_bigquery_dataset" "IAM" {
    project = data.google_project.current.project_id
    location = "asia-northeast1"
    dataset_id = "IAM"
}

resource "google_bigquery_table" "example" {
  dataset_id = google_bigquery_dataset.IAM.dataset_id
  table_id   = "example_table"

  schema = <<EOF
[
  {
    "name": "fieldname",
    "type": "STRING",
    "mode": "REQUIRED"
  }
]
EOF
}