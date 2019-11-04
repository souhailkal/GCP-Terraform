resource "helm_release" "jenkins" {
  provider = "helm.prdops"
  name      = "jenkins"
  chart     = "stable/jenkins"

  set {
    name = "master.installPlugins.0"
    value = "kubernetes:latest"
  }

  set {
    name = "master.installPlugins.1"
    value = "workflow-job:latest"
  }

  set {
    name = "master.installPlugins.2"
    value = "workflow-aggregator:latest"
  }

  set {
    name = "master.installPlugins.3"
    value = "credentials-binding:latest"
  }

  set {
    name = "master.installPlugins.4"
    value = "git:latest"
  }

  set {
    name = "master.installPlugins.5"
    value = "blueocean:latest"
  }


  set {
    name = "persistence.enabled"
    value = true
  }  

  set {
    name = "persistence.existingClaim"
    value = "prdops-jenkins-home-claim"
  }

  set {
    name = "persistence.storageClass"
    value = "ssd"
  }

  set {
    name = "agent.podName"
    value = "jenkins-agent"
  }

  set {
    name = "agent.alwaysPullImage"
    value = true
  }

  set {
    name = "agent.image"
    value = "adriagalin/jenkins-jnlp-slave"
  }

  set {
    name = "agent.imageTag"
    value = "latest"
  }


  set {
   name = "agent.volumes.0.type"
    value = "HostPath"
  }

  set {
    name = "agent.volumes.0.volumeName"
    value = "docker-sock"
  }

  set {
    name = "agent.volumes.0.hostPath"
    value = "/var/run/docker.sock"
  }

  set {
    name = "agent.volumes.0.mountPath"
    value = "/var/run/docker.sock"
  }

}
