resource "google_compute_disk" "prdops-jenkins-home-disk" {
  name = "prdops-jenkins-home-disk"
  type = "pd-ssd"
  zone = "europe-west1-b"
  project = "be-production-operations"
  labels = {
    environment = "production"
    environment = "frontend"
    environment = "operations"
    environment = "pd-standard"
  }
  physical_block_size_bytes = 4096
}

resource "kubernetes_storage_class" "ssd" {
  provider = kubernetes.prdops
  metadata {
    name = "ssd"
  }

  storage_provisioner = "kubernetes.io/gce-pd"
  reclaim_policy = "Retain"
  parameters = {
    type = "pd-ssd"
  }
  volume_binding_mode = "WaitForFirstConsumer"
}

resource "kubernetes_persistent_volume" "prdops-jenkins-home" {
  provider = kubernetes.prdops
  metadata {
    name = "prdops-jenkins-home"
  }
  spec {
    capacity = {
      storage = "8Gi"
    }
    access_modes = [
      "ReadWriteOnce"]
    storage_class_name = "ssd"
    persistent_volume_source {
      gce_persistent_disk {
        pd_name = "prdops-jenkins-home-disk"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "prdops-jenkins-home-claim" {
  provider = kubernetes.prdops
  metadata {
    name = "prdops-jenkins-home-claim"
  }
  wait_until_bound = true
  spec {
    access_modes = [
      "ReadWriteOnce"]
    storage_class_name = "ssd"
    resources {
      requests = {
        storage = "8Gi"
      }
    }
    //volume_name = kubernetes_persistent_volume.prdops-jenkins-home.metadata[0].name
  }
}

resource "google_compute_address" "jenkins-public-addr" {
  name = "jenkins-public-addr"
}

/*resource "kubernetes_service" "jenkinsv2" {
  provider = "kubernetes.prdops"
  metadata {
    name      = "jenkins"
    namespace = "default"
  }
  spec {
    type = "LoadBalancer"
    selector ={
      app = "jenkins"
    }
    port {
      name        = "http"
      port        = 80
      protocol    = "TCP"
      target_port = 8080
    }
  }
}*/

resource "kubernetes_ingress" "jenkins_ingress" {
  provider = "kubernetes.prdops"
  metadata {
    name = "jenkins-ingress"
    namespace = "default"
    annotations = {
      "kubernetes.io/ingress.global-static-ip-name" = google_compute_address.jenkins-public-addr.address
    }
  }

  spec {
    rule {
      host = "jenkins.prdops.tlmq.fr"
      http {
        path {
          backend {
            service_name = helm_release.jenkins.metadata.0.name
            service_port = 80
          }
        }
      }
    }

  }
}

resource "google_dns_record_set" "prdops-jenkins-client-public" {
  provider = google-beta.prdops
  name = "jenkins.${google_dns_managed_zone.prdops-public.dns_name}"
  type = "A"
  ttl = 3600
  managed_zone = google_dns_managed_zone.prdops-public.name
  rrdatas = [google_compute_address.jenkins-public-addr.address]
}


output "jenkins-ingress-public-ip-addr" {
  value = google_compute_address.jenkins-public-addr
}
