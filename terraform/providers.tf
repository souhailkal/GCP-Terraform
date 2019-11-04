provider "google-beta" {
  alias       = "prdapp"
  version     = "~> 2.9"
  credentials = file("../keys/prdops.json")
  project     = "be-production-applications"
  region      = "europe-west1"
}

data "google_client_config" "prdapp-beta" {
  provider = google-beta.prdapp
}

provider "google-beta" {
  alias       = "prdops"
  version     = "~> 2.9"
  credentials = file("../keys/prdops.json")
  project     = "be-production-operations"
  region      = "europe-west1"
}

data "google_client_config" "prdops-beta" {
  provider = google-beta.prdops
}

provider "google-beta" {
  alias       = "nopapp"
  version     = "~> 2.9"
  credentials = file("../keys/prdops.json")
  project     = "be-no-production-applications"
  region      = "europe-west1"
}

data "google_client_config" "nopapp-beta" {
  provider = google-beta.nopapp
}

provider "google-beta" {
  #no alias for default google-beta provider: nopsbx-beta
  credentials = file("../keys/prdops.json")
  project     = "be-no-production-sandbox"
  region      = "europe-west1"
}

data "google_client_config" "nopsbx-beta" {
  provider = google-beta
}

provider "google" {
  alias       = "prdapp"
  version     = "~> 2.9"
  credentials = file("../keys/prdops.json")
  project     = "be-production-applications"
  region      = "europe-west1"
}

data "google_client_config" "prdapp-google" {
  provider = google.prdapp
}

provider "google" {
  alias       = "prdops"
  version     = "~> 2.9"
  credentials = file("../keys/prdops.json")
  project     = "be-production-operations"
  region      = "europe-west1"
}

data "google_client_config" "prdops-google" {
  provider = google.prdops
}

provider "google" {
  alias       = "nopapp"
  version     = "~> 2.9"
  credentials = file("../keys/prdops.json")
  project     = "be-no-production-applications"
  region      = "europe-west1"
}

data "google_client_config" "nopapp-google" {
  provider = google.nopapp
}

provider "google" {
  #no alias for default google provider: nopsbx
  credentials = file("../keys/prdops.json")
  project     = "be-no-production-sandbox"
  region      = "europe-west1"
}

data "google_client_config" "nopsbx-google" {
  provider = google
}


