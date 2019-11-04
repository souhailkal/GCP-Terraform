resource "google_dns_managed_zone" "prdapp-private" {
  provider    = google-beta.prdapp
  name        = "${var.prdapp_name}-private"
  description = "${var.prdapp_desc} private zone"
  dns_name    = "prdapp."
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.prdapp.self_link
    }
  }

  #  peering_config {
  #    target_network {
  #      network_url = "${google_compute_network.prdops.self_link}"
  #    }
  #  }

  labels = {
    production = false
    private    = true
    public     = false
  }
}

resource "google_dns_managed_zone" "prdapp-public" {
  provider    = google-beta.prdapp
  name        = "${var.prdapp_name}-public"
  description = "${var.prdapp_desc} public zone"
  dns_name    = "prdapp.tlmq.fr."
  visibility  = "public"

  labels = {
    production = false
    private    = false
    public     = true
  }
}

