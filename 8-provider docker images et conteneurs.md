# Provider docker images et conteneurs
- Mise en place de la socket si à distance
- Faille de sécurité
- activation de la socket docker

```
cat /etc/systemd/system/docker.service.d/startup_options.conf
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H tcp://192.168.21.103:2375 -H unix:///var/run/docker.sock
```

```
sudo systemctl daemon-reload
sudo systemctl restart docker
```

## Utiliser docker provider
```
provider "docker" {
    host = "tcp://192.168.21.103:2375"
}
```

Rq : possible par la socket unix

- Télécharger une image
```
resource "docker_image" "nginx" {
    name = "nginx:latest"
}
```

- Lancement du conteneur
```
resource "docker_container" "nginx" {
    image = docker_image.nginx.latest
    name = "enginecks"
    ports {
        internal = 80
        external = 80
    }
}
```

main.tf
```
provider "docker" {
    host = "tcp://${var.ssh_host}:2375"
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
}
```

```
docker ps
```
Rien

```
docker images
```

Rien

`terraform init` (car nouveau provider)

`terraform plan` (dit ce qui va réaliser, installer nginx)

```
terraform apply -auto-approve
```

```
curl 192.168.21.103
```

## Si modification nginx en ubuntu

main.tf
```
provider "docker" {
    host = "tcp://${var.ssh_host}:2375"
}

resource "docker_image" "ubuntu" {
    name = "ubuntu:latest"
}
resource "docker_container" "ubuntu" {
    image = docker_image.ubuntu.latest
    name = "ubuntu"
    ports {
        internal = 80
        external = 80
    }
}
```

Si on fait un terraform apply
```
terraform apply
```

Il va donc supprimer l'image nginx, par contre il va créer ubuntu.

SI on fait un docker ps -a, ubuntu on l'a bien.

L'image nginx est supprimé et on a l'image.

Maintenant on observe le côté stateful qui est très pratique.