data "google_project" "project" {
}

terraform {
  required_providers {
    google = {
      version = "~> 3.51"
    }

    google-beta = {
      version = "~> 3.51"
    }
  }
}

provider "google" {
  credentials = ""
  project     = "code-supply"
  region      = "europe-west1"
}

provider "google-beta" {
  credentials = ""
  project     = "code-supply"
  region      = "europe-west1"
}
