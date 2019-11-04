resource "google_container_cluster" "nopapp" {
  provider    = google.nopapp
  name        = var.nopapp_name
  description = "${var.nopapp_desc} cluster"
  location    = "${var.nopapp_region}-b"

  logging_service    = "logging.googleapis.com"
  monitoring_service = "monitoring.googleapis.com"

  remove_default_node_pool = true
  initial_node_count       = 1

  #cluster_ipv4_cidr        = "172.16.0/23"

  #cluster_autoscaling {

  #}

  maintenance_policy {
    daily_maintenance_window {
      start_time = "02:00"
    }
  }
  #addons_config {
  #  horizontal_pod_autoscaling {
  #    disabled = false
  #  }
  #  http_load_balancing {
  #    disabled = false
  #  }
  #  kubernetes_dashboard {
  #    disabled = false
  #  }
  #  network_policy_config {
  #    disabled = false
  #  }
  #  istio_config {
  #    disabled = false
  #    auth     = AUTH_MUTUAL_TLS
  #  }
  #  cloudrun_config {
  #    disabled = false
  #  }
  #}

  #node_config {
  #  tags = [
  #    "production:true",
  #    "environment:production",
  #    "kubernetes:true",
  #  ]
  #}
}

# A node pool is a set of hosts with same properties that
# can grow or be fixed in size and can be selected for a job.
# There can be one big pool of identic nodes, there is
# usually, however, a pool by tier for the cattle (backend
# having more and faster disk), and fixed pools for the pets.

resource "google_container_node_pool" "nopapp-frontend" {
  provider           = google.nopapp
  name               = "${var.nopapp_name}-frontend"
  location           = "${var.nopapp_region}-b"
  cluster            = google_container_cluster.nopapp.name
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

    # Tags are valid identifiers for sources and targets in
    # network firewall settings.
    tags = [
      "production",
      "frontend",
      "applications",
    ]

    # (Kubernetes) Labels can identify groups of hosts when
    # scheduling jobs in Kubernetes.
    labels = {
      cpu       = "standard"
      memory    = "standard"
      disk_size = "standard"
      disk_kind = "standard"
    }

    # (Kubernetes) Metadata can be retrieved when wanting
    # a report on usage. They do not serve as identifier
    # when scheduing.
    metadata = {
      VariousInfoNotIndexed    = "You can put some text here"
      disable-legacy-endpoints = "true"
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

#  resource "google_container_node_pool" "nopapp-backend" {
#    provider           = "google.nopapp"
#    name               = "${var.nopapp_name}-backend"
#    location           = "${var.nopapp_region}"
#    cluster            = "${google_container_cluster.nopapp.name}"
#    initial_node_count = 1
#
#    autoscaling {
#      min_node_count = 3
#      max_node_count = 6
#    }
#
#    node_config {
#      preemptible  = false
#      machine_type = "n1-standard-4"
#
#      disk_size_gb = 100
#      disk_type    = "pd-standard"
#
#      tags = [
#        "production",
#        "backend",
#        "applications",
#      ]
#
#      labels = {
#        cpu       = "standard"
#        memory    = "standard"
#        disk_size = "standard"
#        disk_kind = "standard"
#      }
#
#      metadata {
#        VariousInfoNotIndexed = "You can put some text here"
#      }
#
#      oauth_scopes = [
#        "https://www.googleapis.com/auth/compute",
#        "https://www.googleapis.com/auth/devstorage.read_only",
#        "https://www.googleapis.com/auth/logging.write",
#        "https://www.googleapis.com/auth/monitoring",
#      ]
#    }
#
#    management {
#      auto_repair  = true
#      auto_upgrade = true
#    }
#  }
#
#  resource "google_container_node_pool" "nopapp-management" {
#    provider           = "google.nopapp"
#    name               = "${var.nopapp_name}-management"
#    location           = "${var.nopapp_region}"
#    cluster            = "${google_container_cluster.nopapp.name}"
#    initial_node_count = 1
#
#    autoscaling {
#      min_node_count = 3
#      max_node_count = 5
#    }
#
#    node_config {
#      preemptible  = false
#      machine_type = "n1-standard-4"
#
#      disk_size_gb = 100
#      disk_type    = "pd-standard"
#
#      tags = [
#        "production",
#        "management",
#        "applications",
#      ]
#
#      labels = {
#        cpu       = "standard"
#        memory    = "standard"
#        disk_size = "standard"
#        disk_kind = "standard"
#      }
#
#      metadata {
#        VariousInfoNotIndexed = "You can put some text here"
#      }
#
#      oauth_scopes = [
#        "https://www.googleapis.com/auth/compute",
#        "https://www.googleapis.com/auth/devstorage.read_only",
#        "https://www.googleapis.com/auth/logging.write",
#        "https://www.googleapis.com/auth/monitoring",
#      ]
#    }
#
#    management {
#      auto_repair  = true
#      auto_upgrade = true
#    }
#  }

provider "kubernetes" {
  host             = google_container_cluster.nopapp.endpoint
  token            = data.google_client_config.nopapp-beta.access_token
  load_config_file = false
  client_certificate = base64decode(
    google_container_cluster.nopapp.master_auth[0].client_certificate,
  )
  client_key = base64decode(google_container_cluster.nopapp.master_auth[0].client_key)
  cluster_ca_certificate = base64decode(
    google_container_cluster.nopapp.master_auth[0].cluster_ca_certificate,
  )
}

