resource "google_compute_disk" "default" {
  project = var.project_id

  name = "test-disk2"
  type = "pd-ssd"
  zone = "us-central1-a"
  labels = {
    environment = "dev"
  }
  physical_block_size_bytes = 4096
}


terraform {
  required_providers {
    google-beta = {
      source = "hashicorp/google-beta"
    }
  }
}

# terraform {
#   backend "gcs" {
#     bucket = ""
#     prefix = "auth"
#   }
# }

provider "google-beta" {
  region = "us-west1"
}

# resource "google_iam_workload_identity_pool" "gh_pool" {
#   project                   = var.project_id
#   provider                  = google-beta
#   workload_identity_pool_id = "gh-pool"
# }

# resource "google_iam_workload_identity_pool_provider" "provider" {
#   provider                           = google-beta
#   project                            = var.project_id
#   workload_identity_pool_id          = google_iam_workload_identity_pool.gh_pool.workload_identity_pool_id
#   workload_identity_pool_provider_id = "gh-provider"
#   attribute_mapping = {
#     "google.subject" = "assertion.sub"
#     "attribute.full" = "assertion.repository+assertion.ref"
#   }
#   oidc {
#     allowed_audiences = ["google-wlif"]
#     issuer_uri        = "https://token.actions.githubusercontent.com"
#   }
# }