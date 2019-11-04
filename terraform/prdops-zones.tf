# DNS zones and peerings for PRDOPS.

# Private zone.
resource "google_dns_managed_zone" "prdops-private" {
  provider    = google-beta.prdops
  name        = "${var.prdops_name}-private"
  description = "${var.prdops_desc} private zone"
  dns_name    = "prdops."
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.prdops.self_link
    }
  }

  labels = {
    production = true
    private    = true
    public     = false
  }
}

# Public zone.
resource "google_dns_managed_zone" "prdops-public" {
  provider    = google-beta.prdops
  name        = "${var.prdops_name}-public"
  description = "${var.prdops_desc} public zone"
  dns_name    = "prdops.tlmq.fr."
  visibility  = "public"

  labels = {
    production = true
    private    = false
    public     = true
  }
}

# Bastion public name.
resource "google_dns_record_set" "prdops-ssh-bastion-public" {
  provider     = google-beta.prdops
  name         = "ssh-bastion.${google_dns_managed_zone.prdops-public.dns_name}"
  type         = "A"
  ttl          = 3600
  managed_zone = google_dns_managed_zone.prdops-public.name
  rrdatas      = [google_compute_instance.ssh-bastion.network_interface[0].access_config[0].nat_ip]
}

# Bastion private name.
resource "google_dns_record_set" "prdops-ssh-bastion-private" {
  provider     = google-beta.prdops
  name         = "ssh-bastion.${google_dns_managed_zone.prdops-private.dns_name}"
  type         = "A"
  ttl          = 3600
  managed_zone = google_dns_managed_zone.prdops-private.name
  rrdatas      = [google_compute_instance.ssh-bastion.network_interface[0].network_ip]
}

# Enable PRDOPS resources to query PRDAPP defined private zones.
resource "google_dns_managed_zone" "prdops-queries-prdapp" {
  provider    = google-beta.prdops
  name        = "${var.prdapp_name}-private"
  description = "${var.prdapp_desc} private zone"
  dns_name    = "prdapp."
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.prdops.self_link
    }
  }

  peering_config {
    target_network {
      network_url = google_compute_network.prdapp.self_link
    }
  }

  labels = {
    production = true
    private    = true
    public     = false
  }
}

# Enable PRDOPS resources to query NOPAPP defined private zones.
resource "google_dns_managed_zone" "prdops-queries-nopapp" {
  provider    = google-beta.prdops
  name        = "${var.nopapp_name}-private"
  description = "${var.nopapp_desc} private zone"
  dns_name    = "nopapp."
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.prdops.self_link
    }
  }

  peering_config {
    target_network {
      network_url = google_compute_network.nopapp.self_link
    }
  }

  labels = {
    production = true
    private    = true
    public     = false
  }
}

