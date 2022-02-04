resource "google_storage_bucket" "static-site" {
  name          = "garrettwong-store"
  location      = "EU"
  force_destroy = true

  uniform_bucket_level_access = true
}


terraform {
    required_providers {
        google-beta = {
            source = "hashicorp/google-beta"
        }
    }
}

provider "google-beta" {
    region      = "us-west1"
}

   
variable "project_id" {
  type = string
  description = "The Google Project ID"
}
resource "google_iam_workload_identity_pool" "gh_pool" {
  project                   = var.project_id
  provider                  = google-beta
  workload_identity_pool_id = "gh-pool"
}

resource "google_iam_workload_identity_pool_provider" "provider" {
  provider                           = google-beta
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.gh_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "gh-provider"
  attribute_mapping                  = {
    "google.subject" = "assertion.sub"
    "attribute.full" = "assertion.repository+assertion.ref"
  }
  oidc {
    allowed_audiences = ["google-wlif"]
    issuer_uri        = "https://token.actions.githubusercontent.com"
  }
}