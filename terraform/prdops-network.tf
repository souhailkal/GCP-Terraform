# Production project for operations's network.

# Project's network.
resource "google_compute_network" "prdops" {
  provider                = google.prdops
  name                    = var.prdops_name
  description             = "${var.prdops_desc} VPC"
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

# Project's subnetwork so that we choose network's IP range.
resource "google_compute_subnetwork" "prdops-default" {
  provider      = google.prdops
  name          = "${var.prdops_name}-default"
  description   = "${var.prdops_desc} default subnet"
  network       = google_compute_network.prdops.self_link
  ip_cidr_range = "10.0.0.0/16"
}

# Default firewall rule allows RDP / SSH and is priorised 65534.
resource "google_compute_firewall" "prdops-ingress-default" {
  provider    = google.prdops
  name        = "${var.prdops_name}-ingress-default"
  description = "Forbid any connection from outside by default"
  network     = google_compute_network.prdops.name
  direction   = "INGRESS"
  priority    = 65530
  disabled    = false

  #enable_logging = true #beta
  source_ranges = ["0.0.0.0/0"]

  #source_service_accounts = [ role1, account2... ]
  #source_tags = [ LABEL1, LABEL2... ]
  #target_service_accounts
  #target_tags

  deny {
    protocol = "tcp"
  }

  deny {
    protocol = "udp"
  }

  deny {
    protocol = "icmp"
  }
}

# Allow web access to frontend nodes in the cluster.
resource "google_compute_firewall" "prdops-ingress-frontend" {
  provider      = google.prdops
  name          = "${var.prdops_name}-ingress-frontend"
  description   = "Authorize ICMP and web 'connections' from outside"
  network       = google_compute_network.prdops.name
  direction     = "INGRESS"
  priority      = 1030
  disabled      = false
  source_ranges = ["0.0.0.0/0"]

  #source_tags = [ LABEL1, LABEL2... ]
  target_tags = ["frontend"]

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = [80, 443]
  }
}

