provider "google" {
  credentials = ""
  project     = "code-supply"
  region      = "europe-west1"

  version = "~> 3.30"
}

provider "google-beta" {
  credentials = ""
  project     = "code-supply"
  region      = "europe-west1"

  version = "~> 3.30"
}
