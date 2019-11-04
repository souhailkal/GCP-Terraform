resource "google_container_cluster" "prdops" {
  provider    = google-beta.prdops
  name        = var.prdops_name
  description = "${var.prdops_desc} cluster"
  location    = var.prdops_region

  logging_service    = "logging.googleapis.com"
  monitoring_service = "monitoring.googleapis.com"

  remove_default_node_pool = true
  initial_node_count       = 1

  addons_config {
    istio_config {
      disabled = false
      auth     = "AUTH_MUTUAL_TLS"
    }
  }

  master_auth {
    username = "*****"
    password = "t****"
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "02:00"
    }
  }
}

resource "google_container_node_pool" "prdops-frontend" {
  provider           = google-beta.prdops
  name               = "${var.prdops_name}-frontend"
  location           = var.prdops_region
  cluster            = google_container_cluster.prdops.name
  initial_node_count = 1

  autoscaling {
    min_node_count = 3
    max_node_count = 11
  }

  node_config {
    preemptible  = false
    machine_type = "n1-standard-4"

    disk_size_gb = 100
    disk_type    = "pd-standard" # pd-ssd

    #image_type   = 
    #local_ssd_count = 0

    tags = [
      "production",
      "frontend",
      "operations",
      "pd-standard",
    ]

    labels = {
      cpu       = "standard"
      memory    = "standard"
      disk_size = "standard"
      disk_kind = "standard"
    }

    metadata = {
      VariousInfoNotIndexed = "You can put some text here"
    }

    #service_account = default

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/projecthosting",
      "https://www.googleapis.com/auth/devstorage.full_control",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/devstorage.read_write",
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

provider "kubernetes" {
  host             = google_container_cluster.prdops.endpoint
  alias            = "prdops"
  load_config_file = false
  username         = google_container_cluster.prdops.master_auth[0].username
  password         = google_container_cluster.prdops.master_auth[0].password
  client_certificate = base64decode(
    google_container_cluster.prdops.master_auth[0].client_certificate,
  )
  client_key = base64decode(google_container_cluster.prdops.master_auth[0].client_key)
  cluster_ca_certificate = base64decode(
    google_container_cluster.prdops.master_auth[0].cluster_ca_certificate,
  )
}

resource "kubernetes_service_account" "tiller" {
  provider = kubernetes.prdops
  metadata {
    name      = "terraform-tiller"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "tiller" {
  provider = kubernetes.prdops
  metadata {
    name = "terraform-tiller"
  }

  role_ref {
    kind      = "ClusterRole"
    name      = "cluster-admin"
    api_group = "rbac.authorization.k8s.io"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "kube-system"
  }

  subject {
    kind = "ServiceAccount"
    name = "terraform-tiller"

    api_group = ""
    namespace = "kube-system"
  }
}

provider "helm" {
  alias          = "prdops"
  install_tiller = true
  kubernetes {
    host             = google_container_cluster.prdops.endpoint
    load_config_file = false
    username         = google_container_cluster.prdops.master_auth[0].username
    password         = google_container_cluster.prdops.master_auth[0].password
    client_certificate = base64decode(
      google_container_cluster.prdops.master_auth[0].client_certificate,
    )
    client_key = base64decode(google_container_cluster.prdops.master_auth[0].client_key)
    cluster_ca_certificate = base64decode(
      google_container_cluster.prdops.master_auth[0].cluster_ca_certificate,
    )
  }

  service_account = "terraform-tiller"
  namespace       = "kube-system"
}

