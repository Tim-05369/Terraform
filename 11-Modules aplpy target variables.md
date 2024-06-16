# Modules - Apply & target + variables
## Objectif
Utiliser un autre module
- Target

Rappel : Objectif c'est d'ordoner l'installation/dépendance/utilisation.

Provider va check s'il arrive à se connecter à notre api. Socket docker. Vu qu'il n'est pas encore installé il n'y arrivait pas.


## Module docker
```sh
rm -rf .terraform/ terraform.tfstate* 
mkdir modules/docker_run/
touch modules/docker_run/main.tf
```

modules/docker_run/main.tf
```tf
provider "docker" {
    host = "tcp://${var.ssh_host}:2375"
}

resource "docker_image" "nginx" {
    name = "nginx:latest"
}
resource = "docker_container" "nginx" {
    image = docker_image.nginx.latest
    name = "enginecks"
    ports {
        internal = 80
        external = 80
    }
}
```

```sh
terraform get
```

```
- docker_install in modules/docker_install
- docker_run in modules/docker_run
```

```
terraform init
terraform plan
```

```
Terraform used the selected providers to generate the
following execution plan. Resource actions are
indicated with the following symbols:
  + create

Terraform planned the following actions, but then encountered a problem:

  # module.docker_install.null_resource.ssh_target will be created
  + resource "null_resource" "ssh_target" {
      + id = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
╷
│ Warning: Deprecated attribute
│ 
│   on modules/docker_run/main.tf line 19, in resource "docker_container" "nginx":
│   19:     image = docker_image.nginx.latest
│ 
│ The attribute "latest" is deprecated. Refer to the
│ provider documentation for details.
╵
╷
│ Error: Error pinging Docker server: Cannot connect to the Docker daemon at tcp://192.168.1.26:2375. Is the docker daemon running?
│ 
│   with module.docker_run.provider["registry.terraform.io/kreuzwerker/docker"],
│   on modules/docker_run/main.tf line 10, in provider "docker":
│   10: provider "docker" {
```

Pour palier ce problème :
```
terraform apply -target module.docker_install
```

```
docker -H 192.168.1.26 ps
```

```
terraform apply
```

```
terraform apply -target module.docker_install
```

```
terraform apply -auto-approve
```

```
curl 192.168.1.26
```

Nginx répond bien

Très important de comprendre l'histoire de dépendance.

Qu'on peut la résoudre grâce au target.

Cette question de dépendance cause des difficultés.

On sait désormais utiliser différents modules définir des variables.

On voit qu'il y a d'autres moyen de gérer les dépendances avec AWS, ou autre.