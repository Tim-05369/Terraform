
variable "hosts" {
    default = {
        "127.0.0.1" = "localhost gitlab.local"
        "192.169.1.168" = "gitlab.test"
        "192.169.1.170" = "prometheus.test"
    }
}

resource "null_resource" "hosts" {
    for_each = var.hosts
    provisioner "local-exec" {
        command = "echo '${each.key} ${each.value}' >> hosts.txt"
    }
}