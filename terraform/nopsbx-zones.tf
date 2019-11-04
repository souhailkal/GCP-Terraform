resource "google_dns_managed_zone" "nopsbx-private" {
  provider    = google-beta
  name        = "${var.nopsbx_name}-private"
  description = "${var.nopsbx_desc} private zone"
  dns_name    = "nopsbx."
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.nopsbx.self_link
    }
  }

  labels = {
    production = false
    private    = true
    public     = false
  }
}

resource "google_dns_record_set" "nopsbx-test" {
  provider     = google-beta
  name         = "test.${google_dns_managed_zone.nopsbx-private.dns_name}"
  type         = "A"
  ttl          = 3600
  managed_zone = google_dns_managed_zone.nopsbx-private.name
  rrdatas      = ["1.2.3.4", "2.3.4.5"]
}

