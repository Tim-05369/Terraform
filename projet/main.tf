variable "ssh_host" {}
variable "ssh_user" {}
variable "ssh_key" {}

module "docker_install" {
    source = "./modules/docker_install/"
    ssh_host = var.ssh_host
    ssh_user = var.ssh_user
    ssh_key = var.ssh_key
}

module "docker_run" {
    source = "./modules/docker_run/"
    ssh_host = var.ssh_host
    ssh_user = var.ssh_user
    ssh_key = var.ssh_key
}

module "docker_wordpress" {
    source = "./modules/docker_wordpress/"
    ssh_host = var.ssh_host
    ssh_user = var.ssh_user
    ssh_key = var.ssh_key
    wordpress_port = 8080
}

output "docker_ip_db" {
    value = module.docker_wordpress.docker_ip_db
}

output "docker_ip_wordpress" {
    value = module.docker_wordpress.docker_ip_wordpress
}

output "docker_wordpress_volume" {
    value = module.docker_wordpress.docker_volume
}