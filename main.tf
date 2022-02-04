resource "google_storage_bucket" "static-site" {
  name          = "garrettwong-store"
  location      = "EU"
  force_destroy = true

  uniform_bucket_level_access = true


}