terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.13"
    }
  }
}

resource "docker_volume" "timvol" {
    name = "myvol2"
    driver = "local"
    driver_opts = {
        o = "bind"
        type = "none"
        device = "/usr/data/"
    }
    depends_on = [ null_resource.ssh_target ]
}

provider "docker" {
    host = "tcp://${var.ssh_host}:2375"
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