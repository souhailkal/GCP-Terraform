resource "kubernetes_namespace" "macha_namespace" {
  provider = "kubernetes.prdops"
  metadata {
    annotations = {
      name = "macha-annotation"
    }

    labels = {
      mylabel = "macha-namespace-label"
    }

    name = "macha-namespace"
  }
}



resource "kubernetes_deployment" "macha" {
 provider = "kubernetes.prdops"
 metadata {
    name = "macha"
    namespace = "${kubernetes_namespace.macha_namespace.metadata.0.name}"
    labels ={
      app = "macha"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels ={
        app = "macha"
      }
    }

    template {
      metadata {
        labels ={
          app = "macha"
        }
      }

      spec {
        container {
           name = "macha-client"
           image = "mikadotlmq/macha-client:latest"
           image_pull_policy = "Always"
           port {
             container_port = "3000"
           }
         }
       }
     }
   }
}


resource "kubernetes_service" "macha" {
  provider = "kubernetes.prdops"
  metadata {
    name      = "macha"
    namespace = "${kubernetes_namespace.macha_namespace.metadata.0.name}"
  }
  spec {
    type = "LoadBalancer"
    selector ={
      app = "macha"
    }
    port {
      name        = "http"
      port        = 80
      protocol    = "TCP"
      target_port = 3000
    }
  }
}

resource "kubernetes_ingress" "macha_ingress" {
  provider = "kubernetes.prdops"
  metadata {
    name = "macha-ingress"
    namespace = "${kubernetes_namespace.macha_namespace.metadata.0.name}"
    annotations = {
      "kubernetes.io/ingress.global-static-ip-name" = kubernetes_service.macha.load_balancer_ingress[0].ip
    }
  }

  spec {
    rule {
      host = "macha-client.prdops.tlmq.fr"
      http {
        path {
          backend {
            service_name = kubernetes_service.macha.metadata.0.name
            service_port = 80
          }
        }
      }
    }

  }
}

resource "google_dns_record_set" "prdops-macha-client-public" {
  provider     = google-beta.prdops
  name         = "macha-client.${google_dns_managed_zone.prdops-public.dns_name}"
  type         = "A"
  ttl          = 3600
  managed_zone = google_dns_managed_zone.prdops-public.name
  rrdatas      = [kubernetes_service.macha.load_balancer_ingress[0].ip]
}


output "macha-ingress-public-ip-addr" {
  value = kubernetes_service.macha.load_balancer_ingress[0].ip
}
