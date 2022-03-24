terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
    }
    k3d = {
      source = "pvotal-tech/k3d"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}