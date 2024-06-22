# Chapitre 14. Provider Docker : TP wordpress + mysql
## Objectif
Changer architecture :

```txt
.
├── main.tf
├── modules
│   ├── docker_install
│   │   ├── main.tf
│   │   ├── startup-options.conf
│   │   └── variables.tf
│   └── docker_run
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── nginx.conf
├── terraform.tfstate
├── terraform.tfstate.backup
└── terraform.tfvars
```

en

```txt
.
├── main.tf
├── modules
│   ├── docker_install
│   │   ├── main.tf
│   │   ├── startup-options.conf
│   │   └── variables.tf
│   ├── docker_run
│   │   ├── main.tf
│   │   └── variables.tf
│   └── docker_wordpress
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── nginx.conf
├── terraform.tfstate
├── terraform.tfstate.backup
└── terraform.tfvars
```

On y observe un docker wordpress. On peut imaginer que dans le docker_run il y aurait la gestion mysql...

C'est assez simple.

On se rend dans nos modules :

```sh
mkdir modules/docker_wordpress
```

## Création /srv/wordpress
```tf
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
```

Ajouter automatiquement les variables.

```tf
variable "ssh_host" {}
variable "ssh_user" {}
variable "ssh_key" {}
```

Modifier le main principal en y ajoutant le module:
```tf
module "docker_run" {
    source = "./modules/docker_run/"
    ssh_host = var.ssh_host
    ssh_user = var.ssh_user
    ssh_key = var.ssh_key
}
```

Retourner dans le main.tf du module, créer une connexion au provider "docker".

```tf
provider "docker" {
    host = "tcp://${var.ssh_host}:2375"
}
```

Ensuite on crée un volume (on fait que pour la database dans ce TP)

```tf
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
```

On crée donc un volume docker.
On y attribue un driver local avec comme option :
```
    o = "bind"
    type = "none"
    device = "/srv/wordpress/"
```

Et il dépend de null_resource.ssh_target

Donner la possibiliter de créer un réseau offrant la possibilité de créer la connexion entre les modules.

```tf
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
```

On crée donc un conteneur docker nommé db

image mysql 5.7 (ça date un peu)
on lui informe de toujours relancer ce container à chaque problème.
Variables d'environnements sets par défauts

On déclare le réseau network qu'on a créé juste avant :

```
    networks_advanced {
        name = docker_network.wordpress.name
    }
```

Sur les volumes même principe.

On informe qu'on va se lier au volume créé juste au dessus.

Ensuite on crée un deuxième conteneur (wordpress), celui qui va créer la base.

```
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
```

Même principe.

Nom
Conteneur
Image utilisé
Réseau
Variables d'environnement (DB, PWD)
et les ports qu'on défini au dessus. `var.wordpress_port`

`variable "wordpress_port" {}` > `modules.docker_wordpress.variables`

Et évidemment ajouter dans le main la variable appelé

    wordpress_port = 8080

## Output
Désormais occupons nous des output.

Toujours faire les choses dans l'ordre :
1. Modules output
2. Positionner les outputs dans les objets parents

Le but c'est de voir qu'on peut les récupérer.

Dans main.tf du module docker_wordpress
```tf
output "docker_ip_db" {
    value = docker_container.db.ip_address
}

output "docker_ip_wordpress" {
    value = docker_container.wordpress.ip_address
}

output "docker_volume" {
    value = docker_volume.db_data.driver_opts.device
}
```

Dans main.tf
```tf
output "docker_ip_db" {
    value = module.docker_wordpress.docker_ip_db
}

output "docker_ip_wordpress" {
    value = module.docker_wordpress.docker_ip_wordpress
}

output "docker_wordpress_volume" {
    value = module.docker_wordpress.docker_volume
}
```

Ensuite on fait un 
```tf
terraform apply -auto-approve
```

Et c'est parti. Normalement l'IP (DB & wordpress) sont retourné avec en plus l'emplacement des datas.

Si on fait un docker ps on a bien nos 3 containers.

## A retenir
- **La structure est importante**
- **Intéret des modules supplémentaires.**
- **Structurer les outputs.**
- **Depends on (ne pas forcer si terraform ne gère pas)**
- **Aspect stockage de la DB sur un volume persistant (important au niveau de docker)**
- **Bien passer à chaque fois les éléments quand on a un changement**

Si on change un docker_network avec la valeur toto. ça va regénérer un nouveau conteneur.

Docker network ls

Tout ça c'est le **Côté stateful** de terraform.