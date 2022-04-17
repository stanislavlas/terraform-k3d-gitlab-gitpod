variable "docker_host" {
    description = "Windows: npipe:////.//pipe//docker_engine, Linix: unix:///var/run/docker.sock"
    type        = string
    default     = "unix:///var/run/docker.sock"
}

variable "volumes_host_path" {
    description = "The absolute path to the root of this project"
    type        = string
    default     = "/terraform-k3d-gitlab-gitpod"
}

variable "domain" {
    description = "The domain on which will be Gitpod and Gitlab reachable"
    type        = string
    default     = "example.com"
}

variable "nginx_host_port" {
    type        = number
    default     = 443
}

variable "gitpod_host_port" {
    type        = number
    default     = 2443
}

variable "gitlab_host_port" {
    type        = number
    default     = 1443
}

variable "id_byte_length" {
    type        = number
    default     = 32
}

variable "k3d_disable_load_balancer" {
    type        = bool
    default     = true
}

variable "enable_nginx" {
    type        = bool
    default     = true
}

variable "enable_gitpod" {
    type        = bool
    default     = true
}

variable "enable_gitlab" {
    type        = bool
    default     = true
}

variable "enable_observability" {
    type        = bool
    default     = true
}