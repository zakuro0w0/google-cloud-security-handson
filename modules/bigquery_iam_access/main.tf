data "google_project" "current" {}

resource "google_bigquery_dataset" "dataset_A" {
    project = data.google_project.current.project_id
    location = "asia-northeast1"
    dataset_id = "dataset_A"
}

resource "google_bigquery_dataset" "dataset_B" {
    project = data.google_project.current.project_id
    location = "asia-northeast1"
    dataset_id = "dataset_B"
}

resource "google_service_account" "service_account" {
  account_id   = "bigquery-iam-access"
  display_name = "BigQuery Service Account"
}

# memberに指定したプリンシパルにプロジェクト全体で有効なroleを与える
# resource "google_project_iam_member" "bigquery_role" {
#   project = data.google_project.current.project_id
#   role    = "roles/bigquery.dataViewer"
#   member  = "serviceAccount:${google_service_account.service_account.email}"
# }

# memberに指定したプリンシパルに特定のデータセットに限定したroleを与える
resource "google_bigquery_dataset_iam_member" "dataset_A_access" {
  project = data.google_project.current.project_id
  dataset_id = google_bigquery_dataset.dataset_A.dataset_id
  role = "roles/bigquery.dataViewer"
  member = "serviceAccount:${google_service_account.service_account.email}"
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