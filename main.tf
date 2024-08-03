provider "google" {
  project     = "gc-security-handson"
  region      = "asia-northeast1"
}

resource "google_project_service" "service" {
    for_each = toset([
        "bigquery.googleapis.com",
    ])
    service = each.value
}

module "bigquery_iam_access" {
  source = "./modules/bigquery_iam_access"
}