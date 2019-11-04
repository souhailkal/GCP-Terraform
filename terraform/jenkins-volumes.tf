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
