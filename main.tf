provider "random" {}

provider "k3d" {}

provider "docker" {
  host    = var.docker_host
}

resource "random_id" "clientId" {
  byte_length = var.id_byte_length
}

resource "random_id" "clientSecret" {
  byte_length = var.id_byte_length
}

resource "docker_image" "nginx" {
  name = "nginx"
  keep_locally  = false
}

resource "docker_image" "k3s" {
  name          = "k3s"
  keep_locally  = false
  build {
    path = "k3s"
  }
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.latest
  name  = "reverseProxy"

  volumes {
    host_path      = "${var.volumes_host_path}/certs/fullchain.pem"
    container_path = "/etc/nginx/certs/fullchain.pem"
  }

  volumes {
    host_path      = "${var.volumes_host_path}/certs/privkey.pem"
    container_path = "/etc/nginx/certs/privkey.pem"
  }

  volumes {
    host_path      = "${var.volumes_host_path}/nginx"
    container_path = "/nginx"
  }

  ports {
    external = var.nginx_host_port
    internal = 443
  }

  env = ["DOMAIN=${var.domain}"]

  provisioner "local-exec" {
    command = "docker exec reverseProxy ./nginx/install.bash"
  }
}

resource "k3d_cluster" "gitlab" {
  name    = "gitlab"
  servers = 1
  image   = docker_image.k3s.latest

  volume {
    source      = "${var.volumes_host_path}/gitlab"
    destination = "/gitlab"
  }

  volume {
    source      = "${var.volumes_host_path}/certs"
    destination = "/certs"
  }

  port {
    host_port      = var.gitlab_host_port
    container_port = 443
  }

  env {
    key   = "CLIENT_ID"
    value = "${random_id.clientId.hex}"
  }

  env {
    key   = "CLIENT_SECRET"
    value = "${random_id.clientSecret.hex}"
  }

  env {
    key   = "DOMAIN"
    value = var.domain
  }

  k3d {
    disable_load_balancer = var.k3d_disable_load_balancer
  }

  k3s {
    extra_server_args = [
      "--no-deploy=traefik",
    ]
  }

  provisioner "local-exec" {
    command = "docker exec k3d-gitlab-server-0 ./gitlab/install.bash"
  }
}

resource "k3d_cluster" "gitpod" {
  name    = "gitpod"
  servers = 1
  image   = docker_image.k3s.latest

  volume {
    source      = "${var.volumes_host_path}/workspaces"
    destination = "/var/gitpod/workspaces"
  }

   volume {
    source      = "${var.volumes_host_path}/gitpod"
    destination = "/gitpod"
  }

  volume {
    source      = "${var.volumes_host_path}/certs"
    destination = "/certs"
  }

  port {
    host_port      = var.gitpod_host_port
    container_port = 443
  }

  env {
    key   = "CLIENT_ID"
    value = "${random_id.clientId.hex}"
  }

  env {
    key   = "CLIENT_SECRET"
    value = "${random_id.clientSecret.hex}"
  }

  env {
    key   = "DOMAIN"
    value = var.domain
  }

  k3d {
    disable_load_balancer = var.k3d_disable_load_balancer
  }

  k3s {
    extra_server_args = [
      "--no-deploy=traefik",
      "--node-label=gitpod.io/workload_meta=true",
      "--node-label=gitpod.io/workload_ide=true",
      "--node-label=gitpod.io/workload_workspace_services=true",
      "--node-label=gitpod.io/workload_workspace_regular=true",
      "--node-label=gitpod.io/workload_workspace_headless=true"
    ]
  }

  provisioner "local-exec" {
    command = "docker exec k3d-gitpod-server-0 ./gitpod/install.bash"
  }
}