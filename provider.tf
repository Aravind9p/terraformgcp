provider "google" {
  project = var.gcp_project
  region  = var.region
  zone    = var.zone
}

data "google_client_config" "current" {
  provider = google
}