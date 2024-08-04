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
# resource "google_bigquery_dataset_iam_member" "dataset_A_access" {
#   project = data.google_project.current.project_id
#   dataset_id = google_bigquery_dataset.dataset_A.dataset_id
#   role = "roles/bigquery.dataViewer"
#   member = "serviceAccount:${google_service_account.service_account.email}"
# }

# memberに指定したプリンシパルに特定のテーブルに限定したroleを与える
resource "google_bigquery_table_iam_member" "dataset_A_table_A_access" {
  project = data.google_project.current.project_id
  dataset_id = google_bigquery_dataset.dataset_A.dataset_id
  table_id = google_bigquery_table.table_A.table_id
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
    "name": "id",
    "type": "STRING",
    "mode": "REQUIRED"
  },
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
    "name": "id",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "password",
    "type": "STRING",
    "mode": "REQUIRED"
  }
]
EOF
}

resource "google_data_catalog_taxonomy" "basic_taxonomy" {
  region       = "asia-northeast1"
  display_name = "basic_taxonomy"
  description  = "A collection of policy tags"

  # 管理者であっても権限付与を明示的に行なわないと見れなくなる
  # SELECT *している場合は権限がなくなるので注意が必要
  activated_policy_types = ["FINE_GRAINED_ACCESS_CONTROL"]
}

resource "google_data_catalog_policy_tag" "parent_policy_tag" {
  taxonomy     = google_data_catalog_taxonomy.basic_taxonomy.id
  display_name = "親のポリシータグ"
  description  = "親のポリシータグです"
}

resource "google_data_catalog_policy_tag" "child_policy_tag" {
  taxonomy          = google_data_catalog_taxonomy.basic_taxonomy.id
  display_name      = "子どものポリシータグ"
  description       = "子どものポリシータグです"
  parent_policy_tag = google_data_catalog_policy_tag.parent_policy_tag.name
}

# BigQuery Data Policyのサンプルコード
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_datapolicy_data_policy#example-usage---bigquery-datapolicy-data-policy-routine
# data_masking_policyにBQリモート関数を指定し、関数の実装で機密データをマスキングすると思われる
# google cloudプロジェクト自体が組織に参加していないとこのリソースは作成できない模様(以下のエラーが出てしまう)
# Error creating DataPolicy: googleapi: Error 400: The project **** needs to belong to an organization to manage DataPolicies.
# 
# resource "google_bigquery_datapolicy_data_policy" "data_masking_policy" {
#   location         = "asia-northeast1"
#   data_policy_id   = "data_masking_policy"
#   policy_tag       = google_data_catalog_policy_tag.child_policy_tag.name
#   data_policy_type = "DATA_MASKING_POLICY"  
#   data_masking_policy {
#     routine = google_bigquery_routine.custom_masking_routine.id
#   }
# }

# passwordデータを"X"でマスキングするBQリモート関数
# resource "google_bigquery_routine" "custom_masking_routine" {
#     dataset_id           = google_bigquery_dataset.dataset_A.dataset_id
#     routine_id           = "custom_masking_routine"
#     routine_type         = "SCALAR_FUNCTION"
#     language             = "SQL"
#     data_governance_type = "DATA_MASKING"
#     definition_body      = "SAFE.REGEXP_REPLACE(password, '[0-9]', 'X')"
#     return_type          = "{\"typeKind\" :  \"STRING\"}"

#     arguments {
#       name = "password"
#       data_type = "{\"typeKind\" :  \"STRING\"}"
#     } 
# }