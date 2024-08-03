data "google_project" "current" {}

resource "google_bigquery_dataset" "dataset_A" {
    project = data.google_project.current.project_id
    location = "asia-northeast1"
    dataset_id = "dataset_A"
}

resource "google_service_account" "service_account" {
  account_id   = "bigquery-iam-access"
  display_name = "BigQuery Service Account"
}

resource "google_project_iam_member" "bigquery_role" {
  project = data.google_project.current.project_id
  role    = "roles/bigquery.dataViewer"
  member  = "serviceAccount:${google_service_account.service_account.email}"
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

resource "google_bigquery_table" "table_B" {
  dataset_id = google_bigquery_dataset.dataset_A.dataset_id
  table_id   = "table_B"
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