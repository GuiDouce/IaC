terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.5.0"
    }
  }
}

provider "docker" { host = "tcp://localhost:2375" }

resource "docker_network" "private_network" {
  name = "my_network"
}

resource "docker_image" "nginx" {
  name         = var.docker_image_name
  keep_locally = true
}

resource "docker_container" "nginx" {
  name  = var.docker_container_name
  image = docker_image.nginx.image_id

  networks_advanced {
    name    = docker_network.private_network.name
    aliases = ["nginx"]
  }

  ports {
    internal = var.internal_port
    external = var.external_port
  }

  provisioner "local-exec" {
    command = "curl -s http://localhost:${var.external_port} | grep 'Welcome'"
  }
}

resource "docker_image" "curl_image" {
  name = "appropriate/curl"
}

resource "docker_container" "client" {
  for_each = { for m in var.machines : m.name => m }

  name  = "server-${each.value.name}"
  image = docker_image.curl_image.image_id

  command = ["sh", "-c", "curl -s http://nginx:80 && sleep 30"]

  networks_advanced {
    name = docker_network.private_network.name
  }

  depends_on = [docker_container.nginx]
}

output "nginx_container_id" {
  value = docker_container.nginx.id
}