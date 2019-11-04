variable "prdops_name" {
  default = "be-production-operations"
}

variable "prdops_desc" {
  default = "Operations production"
}

variable "prdops_region" {
  default = "europe-west1"
}

variable "prdapp_name" {
  default = "be-production-applications"
}

variable "prdapp_desc" {
  default = "European applications production"
}

variable "prdapp_region" {
  default = "europe-west1"
}

variable "prdapp_zones" {
  default = ["b", "c", "d"]
}

variable "nopapp_name" {
  default = "be-no-production-applications"
}

variable "nopapp_desc" {
  default = "European applications noprod"
}

variable "nopapp_region" {
  default = "europe-west1"
}

variable "nopsbx_name" {
  default = "be-no-production-sandbox"
}

variable "nopsbx_desc" {
  default = "Sandbox"
}

variable "nopsbx_region" {
  default = "europe-west1"
}


