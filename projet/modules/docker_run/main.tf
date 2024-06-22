terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.13"
    }
  }
}

resource "null_resource" "ssh_target" {
    connection {
        type = "ssh"
        user = var.ssh_user
        host = var.ssh_host
        private_key = file(var.ssh_key)
    }
    provisioner "remote-exec" {
        inline = [
            "sudo mkdir -p /srv/data/",
            "sudo chmod 777 -R /srv/data/",
            "sleep 5s"
        ]
    }
}

provider "docker" {
    host = "ssh://${var.ssh_user}@${var.ssh_host}:22"
}

data "docker_registry_image" "dockerhub" {
    name = "tim053692/terfock:1.0"
}

resource "docker_image" "terfock" {
    name = data.docker_registry_image.dockerhub.name
    pull_triggers = [ data.docker_registry_image.dockerhub.sha256_digest ]
}

resource "docker_volume" "timkeyvol" {
    name = "myvol2"
    driver = "local"
    driver_opts = {
        o = "bind"
        type = "none"
        device = "/srv/data/"
    }
    depends_on = [ null_resource.ssh_target ]
}

resource "docker_network" "tim" {
    name = "mynet"
    driver = "bridge"
    ipam_config {
        subnet = "177.22.0.0/24"
    }
}

resource "docker_image" "nginx" {
    name = "nginx:latest"
}

resource "docker_container" "nginx" {
    image = docker_image.nginx.latest
    name = "enginecks"
    ports {
        internal = 80
        external = 80
    }
    networks_advanced {
        name = docker_network.tim.name
    }
    volumes {
        volume_name = docker_volume.timkeyvol.name
        container_path = "/usr/share/nginx/html/"
    }
}