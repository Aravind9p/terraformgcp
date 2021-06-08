provider "google" {
credentials     = "${file("tfarv-315808-21fc5d1ddfd0.json")}"
project         = "tfarv-315808"
region          = "asia-south1"
zone            = "asia-south1-a"
}

data "google_client_config" "current" {
    provider = google
}