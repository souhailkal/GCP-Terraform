resource "google_compute_network" "prdapp" {
  provider                = google.prdapp
  name                    = var.prdapp_name
  description             = "${var.prdapp_desc} VPC"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "prdapp-default" {
  provider      = google.prdapp
  name          = "${var.prdapp_name}-default"
  description   = "${var.prdops_desc} default subnet"
  network       = google_compute_network.prdapp.self_link
  ip_cidr_range = "10.1.0.0/16"
}

# Default firewall rule allows RDP / SSH and is priorised 65534.
resource "google_compute_firewall" "prdapp-ingress-default" {
  provider    = google.prdapp
  name        = "${var.prdapp_name}-ingress-default"
  description = "Forbid any connection from outside by default"
  network     = google_compute_network.prdapp.name
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

# Allows web access to frontend nodes in the cluster.
resource "google_compute_firewall" "prdapp-ingress-frontend" {
  provider    = google.prdapp
  name        = "${var.prdapp_name}-ingress-frontend"
  description = "Authorize ICMP and web 'connections' from outside"
  network     = google_compute_network.prdapp.name
  direction   = "INGRESS"
  priority    = 1030
  disabled    = false

  #enable_logging = true #beta
  source_ranges = ["0.0.0.0/0"]

  #source_service_accounts = [ role1, account2... ]
  #source_tags = [ LABEL1, LABEL2... ]
  #target_service_accounts
  target_tags = ["frontend"]

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = [80, 443]
  }
}

