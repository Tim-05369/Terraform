# Module
## Définition
Modules : C'est un regroupement de fichier tf avec une cohérence en matière de resources.

Route module c'est le répertoire principal dans lequel on était pour faire notre main.tf

Module terraform = rôle ansible

Possibilité de partager des modules (Registry terraform)

Les modules partagé sont souvent autour du clour : https://registry.terraform.io/

Module = répertoires + fichiers tf

## Pour appeler un module

utilisation d'un module :
```
moduke "monmodule" {
    source = "./rep_module
}
```

Princip d'héritage du provider
- Par défaut celui du fichier dans lequel il est appelé
- possibilité de préciser le provider

Possibilité d'instancier plusieurs fois le même module avec plusieurs nom différent mais en appelant le même répertoire.
```
module "instance1" {
    source = "./rep_module
}
module "instance2" {
    source = "./rep_module
}
```

## Structure d'un module :
- README.md
- main.tf
- variables.tf
- outputs.tf


- README.md
- main.tf
- variables.tf
- outputs.tf
- ...
- modules/
  - nestedA/
    - README.md
    - variables.tf
    - main.tf
    - outputs.tf
  - nestedB/
    - .../
- examples/
  - exampleA/
    - main.tf
  - exampleB/
    - .../

L'idée recommande d'utiliser des module principaux. Puis des sous modules avec des exemples d'utilisation.

## Installation d'un module
```
terraform get
terraform init
```

On peut gérer les dépendances grâce aux modules :
```
terraform apply -targer=module.docker
terraform apply -targer=module.postgres
```

Tq: ou via les variables

- Problématique de la vidéo précédente

cf problème de dépendance d'installation de docker avant de jouer le provider docker.

On avait rencontré un problème lors du dernier test. 

ERREUR :
```
bloc null_ressource

bloc docker
```

```tf
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

provider "docker" {
    host = "tcp://${var.ssh_host}:2375
}

resource "docker_image" "nginx" {
    name = "nginx:latest"
}

resource "docker_container "nginx" {
    image = docker_image.nginx.latest
    name = "enginecks
    ports {
        internal = 80
        external = 80
    }
}

output "host" {
    value = var.ssh_host
}
output "user" {
    value = var.ssh_user
}
```

La problématique reste la même on peut pas gérer la dépendance avec les fichiers non plus.

La on va conserver ce code. Je vais récupérer ma clé ssh (clé public).

```
terraform init
terraform apply
```

Lors de la connexion, il check la connexion au provider docker. L'ordre pose problème.

Quand on fait notre terraform apply :
Il check le lancement au fichier principal

Error: Error pinging Docker daemon at tcp://192.168.21.103:2375.

Dans le prochain TP nous checkerons comment on peut gérer l'ordre pour taper 2 modules et utiliser des targets pour lister l'ordre des modules.

