# DNS zones and peerings for PRDOPS.

# Private zone.
resource "google_dns_managed_zone" "nopapp-private" {
  provider    = google-beta.nopapp
  name        = "${var.nopapp_name}-private"
  description = "${var.nopapp_desc} private zone"
  dns_name    = "nopapp."
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.nopapp.self_link
    }
  }

  labels = {
    production = false
    private    = true
    public     = false
  }
}

# Public zone.
resource "google_dns_managed_zone" "nopapp-public" {
  provider    = google-beta.nopapp
  name        = "${var.nopapp_name}-public"
  description = "${var.nopapp_desc} public zone"
  dns_name    = "nopapp.tlmq.fr."
  visibility  = "public"

  labels = {
    production = false
    private    = false
    public     = true
  }
}

# Enable NOPAPP resources to query PRDOPS defined private zones.
resource "google_dns_managed_zone" "nopapp-queries-prdops" {
  provider    = google-beta.nopapp
  name        = "${var.prdops_name}-private"
  description = "${var.prdops_desc} private zone"
  dns_name    = "prdops."
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.nopapp.self_link
    }
  }

  peering_config {
    target_network {
      network_url = google_compute_network.prdops.self_link
    }
  }

  labels = {
    production = true
    private    = true
    public     = false
  }
}

