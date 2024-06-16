# Remot_exec : installation de docker & socket
**TER**
Copier clé publique 

```sh
#paste in 
vim .ssh/authorised_key
```

```sh
ssh -i ~/.ssh/id_rsa tim@192.168.21.103
```

vim .ssh/authorised_key

sshkey = "/.ssh/id_rsa.pub"
sshuser = "tim"
ssh_host = "192.168.21.103"

```
vim main.tf
```

```
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
            "sudo apt update -qq >/dev/null",
            "curl -fsSL https://get.docker.com -o get-docker.sh"
            "sudo chmod 755 get-docker.sh",
            "sudo ./get-docker.sh >/dev/null"
        ]
    }
    provisioner "file" {
        source = "startup-options.conf"
        destination = "tmp/startup-options.conf"
    }
    provisioner "remote-exec" {
        inline = [
            "sudo mkdir -p /etc/systemd/system/docker.service.d/",
            "sudo cp /tmp/startup-options.conf /etc/systemd/system/docker.service.d/startup_options.conf",
            "sudo systemctl daemon-reload",
            "sudo systemctl restart docker",
            "sudo usermod -aG docker tim"
        ]
    }
}

output "host" {
    value = var.ssh_host
}
output "user" {
    value = var.ssh_user
}
```

```
vim startup-options.conf
```

Fichier qui permet de passer les informations de setting à docker D pour lui dire lance la socket et lance la sur l'ip 192.168.21.103:2375 -M unix:///var/run/docker.sock
possibilité de lancer également la socket unix

```
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -M tcp://192.168.21.103:2375 -M unix:///var/run/docker.sock
```


```
terraform init
```

```
terraform plan
```

```
terraform apply -auto-approve
```
