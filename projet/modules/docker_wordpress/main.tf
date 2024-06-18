resource "null_resource" "ssh_target" {
    connection {
        type = "ssh"
        user = var.ssh_user
        host = var.ssh_host
        private_key = file(var.ssh_key)
    }

    provisioner "remote-exec" {
        inline = [
            "sudo mkdir -p /srv/wordpress/",
            "sudo chmod 777 -R /srv/wordpress/",
            "sleep 5s"
        ]
    }
}

provider "docker" {
    host = "tcp://${var.ssh_host}:2375"
}

resource "docker_volume" "db_data" {
    name = "db_data"
    driver = "local"
    driver_opts = {
        o = "bind"
        type = "none"
        device = "/srv/wordpress/"
    }
    depends_on = [ null_resource.ssh_target ]
}

resource "docker_network" "wordpress" {
    name = "wordpress_net"
}

resource "docker_container" "db" {
    name = "db"
    image = "mysql:5.7"
    restart = "always"
    env = [
        "MYSQL_ROOT_PASSWORD=wordpress",
        "MYSQL_PASSWORD=wordpress",
        "MYSQL_USER=wordpress",
        "MYSQL_DATABASE=wordpress"
    ]
    networks_advanced {
        name = docker_network.wordpress.name
    }
    volumes {
        host_path = "/srv/wordpress/"
        container_path = "/var/lib/mysql/"
        volume_name = docker_volume.db_data.name
    }
}

resource "docker_container" "wordpress" {
    name = "wordpress"
    image = "wordpress:latest"
    restart = "always"
    networks_advanced {
        name = docker_network.wordpress.name
    }
    env = [
        "WORDPRESS_DB_HOST=db:3306",
        "WORDPRESS_DB_PASSWORD=wordpress"
    ]
    ports {
        internal = 80
        external = var.wordpress_port
    }
}

output "docker_ip_db" {
    value = docker_container.db.ip_address
}

output "docker_ip_wordpress" {
    value = docker_container.wordpress.ip_address
}

output "docker_volume" {
    value = docker_volume.db_data.driver_opts.device
}