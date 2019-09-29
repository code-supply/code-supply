provider "google" {
  credentials = ""
  project     = var.gcp_project
  region      = var.gcp_region

  version = "~> 2.5"
}
