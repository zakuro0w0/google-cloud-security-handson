data "google_project" "current" {}

resource "google_bigquery_dataset" "dataset_A" {
    project = data.google_project.current.project_id
    location = "asia-northeast1"
    dataset_id = "dataset_A"
}

resource "google_bigquery_table" "table_A" {
  dataset_id = google_bigquery_dataset.dataset_A.dataset_id
  table_id   = "table_A"
  deletion_protection = false

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