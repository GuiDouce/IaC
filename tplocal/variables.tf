variable "docker_image_name" {
  type    = string
  default = "nginx:latest"
}

variable "docker_container_name" {
  type    = string
  default = "mon-serveur-web"
}

variable "external_port" {
  type    = number
  default = 8080
}

variable "internal_port" {
  type    = number
  default = 80
}

variable "client_count" {
  type    = number
  default = 3
}

variable "server_names" {
  type    = list(string)
  default = ["1", "2", "3"]
}

variable "machines" {
  type = list(object({
    name      = string
    vcpu      = number
    disk_size = number
    region    = string
  }))

  validation {
    condition     = alltrue([for m in var.machines : m.vcpu >= 2 && m.vcpu <= 64])
    error_message = "vCPU doit être entre 2 et 64."
  }

  validation {
    condition     = alltrue([for m in var.machines : m.disk_size >= 20])
    error_message = "Le disque doit être >= 20 Go."
  }

  validation {
    condition     = alltrue([for m in var.machines : contains(["eu-west-1", "us-east-1", "ap-southeast-1"], m.region)])
    error_message = "Région non autorisée."
  }
}