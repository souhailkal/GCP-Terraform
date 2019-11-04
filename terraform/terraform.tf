terraform {
  backend "gcs" {
    prefix      = "state"
    credentials = "../keys/prdops.json"
    #project     = "be-production-operations"
    bucket      = "be-production-operations-tfstate"
  }
}

