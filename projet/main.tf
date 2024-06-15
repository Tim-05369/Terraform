variable "ssh_host" {}
variable "ssh_user" {}
variable "ssh_key" {}
resource "null_resource" "ssh_target" {
    connection {
        type = "ssh"
        user = var.ssh_user
        host = var.ssh_host
        private_key = file(var.ssh_key)
    }
    provisioner "remote-exec" {
        inline = [
            "apt update -qq >/dev/null",
            "apt install -qq -y nginx >/dev/null"
        ]
    }
}
