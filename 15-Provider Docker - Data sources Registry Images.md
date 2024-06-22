# Provideer Docker : data source, registry, images...
## Idempotence
Relancer un terraform apply et regarder ce qui se place.

Le résultat est pas bon car si on rejoue le terraform, il va supprimer les conteneurs pour les recréer. C'est très mauvais car on va avoir le sentiments que tout va bien mais les conteneurs vont être recréer.

## 
```
terraform apply -auto-approve
```

C'est pas bon car derrière on a en downtime.

C'est pas bon en IaC. Il faut gérer cet élément la.

Pour gérer ça on va :
- Utiliser une source registry (Data source) - Qui ne peut pas être modifiable
- Comment on utilise les images et comment terraform les récupères, les pulls
- Mise en place de l'idem potence dans notre module wordpress.

## Commencement
```th
terraform show
```

Pour l'image database et l'image wordpress on se base sur un nom qui est fixé dans la ressource et c'est pas bon du tout.

Docker_container

C'est pas satisfaisant.

Nous on va interroger une registry as datasource. Et on va voir comment ça va évoluer.

Terraform est très intelligent car même si le tag de l'image n'évolue pas, il récupère juste le tag de l'image et même s'il n'évolue pas, il récupère le sha256 il le compare et il fait la modification si le sha256 a évolué.

```th
EXAMPLE
data "docker_registry_image" "myimg" {
    name = "priximmo/testter:1.0"
}
```

On va ensuite utilisé l'image via la ressource docker image.
```th
EXAMPLE
resource "docker_image" "testter" {
    name = data.docker_registry_image.myimg.name
    pull_triggers = [ data.docker_registry_image.myimg.sha256_digest ]
}
```

Rq : importance du trigger

## Application / Test
création d'un dockerfile dans `testSha256`

On a la registry qui est plus connu.

On monte l'image `docker build`

```sh
docker build -t tim053692/terfock:1.0
```

```sh
docker push docker.io/tim053692/terfock:1.0
```

L'image a bien été créé sur docker hub. Avec le tag 1.0.


Nous ce qu'on souhaite après c'est accéder au projet, modificer /`docker_run/main.tf`


```th
data "docker_registry" "dockerhub" {
    name = "tim053692/terfock:1.0"
}
```

ça va permettre d'aller checker, consulter à la demande, les éléments et attributs qui sont stockés sur docker_hub de cette image ci.

On va pouvoir check si l'image a été modifié puis la modifier.

```th
resource "docker_registry_image" "terfock" {
    name = data.docker_registry_image.dockerhub.name
    pull_triggers = [ data.docker_registry_image.dockerhub.sha256_digest ]
}
```

- pull_triggers - tu vas pull des lors que quelque chose va évoluer.

dockerhub datasource -> sha256_digest On déclenche le pull que dès lors que celui-ci évolue.

On fait évoluer notre dockerfile

```dockerfile
FROM alpine

RUN echo hello > /tmp/tim
RUN echo hello2 > /tmp/tim
```

On rebuild 

```sh
docker build -t tim053692/terfock:1.0
```

```sh
docker push docker.io/tim053692/terfock:1.0
```

Comme le SHA256 a évoluer on repush notre image :
```th
docker push docker.io/tim053692/terfock:1.0 .
```

Si on raffraichi sur la page on a toujours le tag et l'id 256 a évoluer


`terraform apply`

Il met à jour car le tag a évolué.

ça c'est très très important !

```sh
Apply complete! Resources: 4 added, 0 changed, 4 destroyed.
```

```sh
module.docker_run.null_resource.ssh_target: Refreshing state... [id=5231299053336184424]
module.docker_install.null_resource.ssh_target: Refreshing state... [id=1109116924981371443]
module.docker_wordpress.null_resource.ssh_target: Refreshing state... [id=5867348079461281823]
module.docker_run.data.docker_registry_image.dockerhub: Reading...
module.docker_run.docker_network.tim: Refreshing state... [id=149d52ed3c11054f5156e7cc7c3b55f2b44361599bac5a8245826cb04c94c13d]
module.docker_run.docker_image.nginx: Refreshing state... [id=sha256:dde0cca083bc75a0af14262b1469b5141284b4399a62fef923ec0c0e3b21f5bcnginx:latest]
module.docker_wordpress.docker_network.wordpress: Refreshing state... [id=782937cf7effe79d6333decc7f41450a53fa5fae08bd96ff10cf78ef7731682a]
module.docker_run.docker_volume.timkeyvol: Refreshing state... [id=myvol2]
module.docker_wordpress.docker_volume.db_data: Refreshing state... [id=db_data]
module.docker_run.data.docker_registry_image.dockerhub: Read complete after 1s [id=sha256:78410999ff139c44af012ebee21a66d628d6f9ace7a353d4c6420e0e4a3ec6d1]
module.docker_run.docker_image.terfock: Refreshing state... [id=sha256:60083f579d584a39bcc5315fdef4e1273a43404ef204d2fd9716fad188d4566ctim053692/terfock:1.0]
module.docker_wordpress.docker_container.wordpress: Refreshing state... [id=2d1af7297a2eb4810993b6918dee19b4d62e10034974adb3d3ca9aa3d2fa2f0e]
module.docker_wordpress.docker_container.db: Refreshing state... [id=b12d1bec240bc68b7928e8af2f3a672329ab4db3981d07cc37b1042437bc6782]
module.docker_run.docker_container.nginx: Refreshing state... [id=b4f1440033075686f5294bc2a10ceaa1e04df72d76eb94fba1ab5cbe7bf06deb]

Terraform used the selected providers to generate the following execution plan. Resource actions are
indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # module.docker_run.docker_container.nginx must be replaced
-/+ resource "docker_container" "nginx" {
      + bridge                                      = (known after apply)
      ~ command                                     = [
          - "nginx",
          - "-g",
          - "daemon off;",
        ] -> (known after apply)
      + container_logs                              = (known after apply)
      - cpu_shares                                  = 0 -> null
      - dns                                         = [] -> null
      - dns_opts                                    = [] -> null
      - dns_search                                  = [] -> null
      ~ entrypoint                                  = [
          - "/docker-entrypoint.sh",
        ] -> (known after apply)
      ~ env                                         = [] -> (known after apply)
      + exit_code                                   = (known after apply)
      ~ gateway                                     = "177.22.0.1" -> (known after apply)
      - group_add                                   = [] -> null
      ~ hostname                                    = "b4f144003307" -> (known after apply)
      ~ id                                          = "b4f1440033075686f5294bc2a10ceaa1e04df72d76eb94fba1ab5cbe7bf06deb" -> (known after apply)
      ~ init                                        = false -> (known after apply)
      ~ ip_address                                  = "177.22.0.2" -> (known after apply)
      ~ ip_prefix_length                            = 24 -> (known after apply)
      ~ ipc_mode                                    = "private" -> (known after apply)
      - links                                       = [] -> null
      ~ log_driver                                  = "json-file" -> (known after apply)
      - log_opts                                    = {} -> null
      - max_retry_count                             = 0 -> null
      - memory                                      = 0 -> null
      - memory_swap                                 = 0 -> null
        name                                        = "enginecks"
      ~ network_data                                = [
          - {
              - gateway                   = "177.22.0.1"
              - global_ipv6_prefix_length = 0
              - ip_address                = "177.22.0.2"
              - ip_prefix_length          = 24
              - network_name              = "mynet"
                # (2 unchanged attributes hidden)
            },
        ] -> (known after apply)
      - network_mode                                = "bridge" -> null # forces replacement
      - privileged                                  = false -> null
      - publish_all_ports                           = false -> null
      ~ runtime                                     = "runc" -> (known after apply)
      ~ security_opts                               = [] -> (known after apply)
      ~ shm_size                                    = 64 -> (known after apply)
      ~ stop_signal                                 = "SIGQUIT" -> (known after apply)
      ~ stop_timeout                                = 0 -> (known after apply)
      - storage_opts                                = {} -> null
      - sysctls                                     = {} -> null
      - tmpfs                                       = {} -> null
        # (20 unchanged attributes hidden)

      - volumes {
          - container_path = "/usr/share/nginx/html/" -> null
          - read_only      = false -> null
          - volume_name    = "myvol2" -> null
            # (2 unchanged attributes hidden)
        }
      + volumes {
          + container_path = "/usr/share/nginx/html/"
          + volume_name    = "myvol2"
            # (2 unchanged attributes hidden)
        }

        # (2 unchanged blocks hidden)
    }

  # module.docker_run.docker_image.terfock must be replaced
-/+ resource "docker_image" "terfock" {
      ~ id            = "sha256:60083f579d584a39bcc5315fdef4e1273a43404ef204d2fd9716fad188d4566ctim053692/terfock:1.0" -> (known after apply)
      ~ image_id      = "sha256:60083f579d584a39bcc5315fdef4e1273a43404ef204d2fd9716fad188d4566c" -> (known after apply)
      ~ latest        = "sha256:60083f579d584a39bcc5315fdef4e1273a43404ef204d2fd9716fad188d4566c" -> (known after apply)
        name          = "tim053692/terfock:1.0"
      + output        = (known after apply)
      ~ pull_triggers = [ # forces replacement
          - "sha256:abcb729a6ae195c864558c99f9bb51689ed0f01bb7f6a3838e57d7aeb7e23933",
          + "sha256:78410999ff139c44af012ebee21a66d628d6f9ace7a353d4c6420e0e4a3ec6d1",
        ]
      ~ repo_digest   = "tim053692/terfock@sha256:abcb729a6ae195c864558c99f9bb51689ed0f01bb7f6a3838e57d7aeb7e23933" -> (known after apply)
    }

  # module.docker_wordpress.docker_container.db must be replaced
-/+ resource "docker_container" "db" {
      + bridge                                      = (known after apply)
      ~ command                                     = [
          - "mysqld",
        ] -> (known after apply)
      + container_logs                              = (known after apply)
      - cpu_shares                                  = 0 -> null
      - dns                                         = [] -> null
      - dns_opts                                    = [] -> null
      - dns_search                                  = [] -> null
      ~ entrypoint                                  = [
          - "docker-entrypoint.sh",
        ] -> (known after apply)
      + exit_code                                   = (known after apply)
      ~ gateway                                     = "172.18.0.1" -> (known after apply)
      - group_add                                   = [] -> null
      ~ hostname                                    = "b12d1bec240b" -> (known after apply)
      ~ id                                          = "b12d1bec240bc68b7928e8af2f3a672329ab4db3981d07cc37b1042437bc6782" -> (known after apply)
      ~ image                                       = "sha256:5107333e08a87b836d48ff7528b1e84b9c86781cc9f1748bbc1b8c42a870d933" -> "mysql:5.7" # forces replacement
      ~ init                                        = false -> (known after apply)
      ~ ip_address                                  = "172.18.0.2" -> (known after apply)
      ~ ip_prefix_length                            = 16 -> (known after apply)
      ~ ipc_mode                                    = "private" -> (known after apply)
      - links                                       = [] -> null
      ~ log_driver                                  = "json-file" -> (known after apply)
      - log_opts                                    = {} -> null
      - max_retry_count                             = 0 -> null
      - memory                                      = 0 -> null
      - memory_swap                                 = 0 -> null
        name                                        = "db"
      ~ network_data                                = [
          - {
              - gateway                   = "172.18.0.1"
              - global_ipv6_prefix_length = 0
              - ip_address                = "172.18.0.2"
              - ip_prefix_length          = 16
              - network_name              = "wordpress_net"
                # (2 unchanged attributes hidden)
            },
        ] -> (known after apply)
      - network_mode                                = "bridge" -> null # forces replacement
      - privileged                                  = false -> null
      - publish_all_ports                           = false -> null
      ~ runtime                                     = "runc" -> (known after apply)
      ~ security_opts                               = [] -> (known after apply)
      ~ shm_size                                    = 64 -> (known after apply)
      + stop_signal                                 = (known after apply)
      ~ stop_timeout                                = 0 -> (known after apply)
      - storage_opts                                = {} -> null
      - sysctls                                     = {} -> null
      - tmpfs                                       = {} -> null
        # (20 unchanged attributes hidden)

      - volumes {
          - container_path = "/var/lib/mysql/" -> null
          - host_path      = "/srv/wordpress/" -> null
          - read_only      = false -> null
          - volume_name    = "db_data" -> null
            # (1 unchanged attribute hidden)
        }
      + volumes {
          + container_path = "/var/lib/mysql/"
          + host_path      = "/srv/wordpress/"
          + volume_name    = "db_data"
            # (1 unchanged attribute hidden)
        }

        # (1 unchanged block hidden)
    }

  # module.docker_wordpress.docker_container.wordpress must be replaced
-/+ resource "docker_container" "wordpress" {
      + bridge                                      = (known after apply)
      ~ command                                     = [
          - "apache2-foreground",
        ] -> (known after apply)
      + container_logs                              = (known after apply)
      - cpu_shares                                  = 0 -> null
      - dns                                         = [] -> null
      - dns_opts                                    = [] -> null
      - dns_search                                  = [] -> null
      ~ entrypoint                                  = [
          - "docker-entrypoint.sh",
        ] -> (known after apply)
      + exit_code                                   = (known after apply)
      ~ gateway                                     = "172.18.0.1" -> (known after apply)
      - group_add                                   = [] -> null
      ~ hostname                                    = "2d1af7297a2e" -> (known after apply)
      ~ id                                          = "2d1af7297a2eb4810993b6918dee19b4d62e10034974adb3d3ca9aa3d2fa2f0e" -> (known after apply)
      ~ image                                       = "sha256:372ef0d81712bd1fbcaa3aff6a207409a26666bf5330c100f340d9d3a8cac6c7" -> "wordpress:latest" # forces replacement
      ~ init                                        = false -> (known after apply)
      ~ ip_address                                  = "172.18.0.3" -> (known after apply)
      ~ ip_prefix_length                            = 16 -> (known after apply)
      ~ ipc_mode                                    = "private" -> (known after apply)
      - links                                       = [] -> null
      ~ log_driver                                  = "json-file" -> (known after apply)
      - log_opts                                    = {} -> null
      - max_retry_count                             = 0 -> null
      - memory                                      = 0 -> null
      - memory_swap                                 = 0 -> null
        name                                        = "wordpress"
      ~ network_data                                = [
          - {
              - gateway                   = "172.18.0.1"
              - global_ipv6_prefix_length = 0
              - ip_address                = "172.18.0.3"
              - ip_prefix_length          = 16
              - network_name              = "wordpress_net"
                # (2 unchanged attributes hidden)
            },
        ] -> (known after apply)
      - network_mode                                = "bridge" -> null # forces replacement
      - privileged                                  = false -> null
      - publish_all_ports                           = false -> null
      ~ runtime                                     = "runc" -> (known after apply)
      ~ security_opts                               = [] -> (known after apply)
      ~ shm_size                                    = 64 -> (known after apply)
      ~ stop_signal                                 = "SIGWINCH" -> (known after apply)
      ~ stop_timeout                                = 0 -> (known after apply)
      - storage_opts                                = {} -> null
      - sysctls                                     = {} -> null
      - tmpfs                                       = {} -> null
      - working_dir                                 = "/var/www/html" -> null
        # (19 unchanged attributes hidden)

        # (2 unchanged blocks hidden)
    }

Plan: 4 to add, 0 to change, 4 to destroy.

Changes to Outputs:
  ~ docker_ip_db            = "172.18.0.2" -> (known after apply)
  ~ docker_ip_wordpress     = "172.18.0.3" -> (known after apply)
╷
│ Warning: Deprecated attribute
│ 
│   on modules/docker_run/main.tf line 63, in resource "docker_container" "nginx":
│   63:     image = docker_image.nginx.latest
│ 
│ The attribute "latest" is deprecated. Refer to the provider documentation for details.
│ 
│ (and 7 more similar warnings elsewhere)
╵

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

module.docker_run.docker_image.terfock: Destroying... [id=sha256:60083f579d584a39bcc5315fdef4e1273a43404ef204d2fd9716fad188d4566ctim053692/terfock:1.0]
module.docker_wordpress.docker_container.db: Destroying... [id=b12d1bec240bc68b7928e8af2f3a672329ab4db3981d07cc37b1042437bc6782]
module.docker_wordpress.docker_container.wordpress: Destroying... [id=2d1af7297a2eb4810993b6918dee19b4d62e10034974adb3d3ca9aa3d2fa2f0e]
module.docker_run.docker_container.nginx: Destroying... [id=b4f1440033075686f5294bc2a10ceaa1e04df72d76eb94fba1ab5cbe7bf06deb]
module.docker_run.docker_image.terfock: Destruction complete after 5s
module.docker_run.docker_image.terfock: Creating...
module.docker_run.docker_container.nginx: Destruction complete after 5s
module.docker_run.docker_container.nginx: Creating...
module.docker_wordpress.docker_container.db: Destruction complete after 6s
module.docker_wordpress.docker_container.db: Creating...
module.docker_wordpress.docker_container.wordpress: Destruction complete after 7s
module.docker_wordpress.docker_container.wordpress: Creating...
module.docker_run.docker_image.terfock: Still creating... [10s elapsed]
module.docker_run.docker_container.nginx: Still creating... [10s elapsed]
module.docker_wordpress.docker_container.db: Still creating... [10s elapsed]
module.docker_wordpress.docker_container.wordpress: Still creating... [10s elapsed]
module.docker_wordpress.docker_container.db: Creation complete after 11s [id=9a262c0d744517285cdd471bfbc0371e53f7ff16eae4d2ef5bc332d2eb7c14f1]
module.docker_run.docker_container.nginx: Creation complete after 13s [id=a8e3d4a1dc897b170d83d1aa63b4efcd14c00bd3eee563a2d9f3b02e712e9bcf]
module.docker_run.docker_image.terfock: Creation complete after 13s [id=sha256:0923cb22388fa33be72557c65a1b96bdd561e632d350c8527297cedcd4281dd3tim053692/terfock:1.0]
module.docker_wordpress.docker_container.wordpress: Creation complete after 12s [id=320669c31bcff5ec6f172d749b465784610824370f06b0d00050c6f2883bad3e]
╷
│ Warning: Deprecated attribute
│ 
│   on modules/docker_run/main.tf line 63, in resource "docker_container" "nginx":
│   63:     image = docker_image.nginx.latest
│ 
│ The attribute "latest" is deprecated. Refer to the provider documentation for details.
│ 
│ (and 3 more similar warnings elsewhere)
╵

Apply complete! Resources: 4 added, 0 changed, 4 destroyed.

Outputs:

docker_ip_db = "172.18.0.2"
docker_ip_wordpress = "172.18.0.3"
docker_wordpress_volume = "/srv/wordpress/"
```

Maintenant on s'intéresse à la gestion de notre idempotence.

`terraform plan`

Nos 2 conteneurs sont modifié, on va éviter ça.

Premier c'est la gestion de l'image.

`modules/docker_wordpress/main.tf`


Dans docker_wordpress.th
```th
data "docker_registry_image" "mysql" {
    name = "mysql:5.7"
}

data "docker_registry_image" "wordpress" {
    name = "wordpress:latest"
}
```

Objectif c'est récupérer l'image pour gérer l'idempotence.

Update images :
```th
resource "docker_container" "db" {
    name = "db"
    image = "docker_image.mysql.name"
    [...]
}
```

```th
resource "docker_container" "mysql" {
    name = "wordpress"
    image = "docker_image.wordpress.name"
    [...]
}
```

On va voir que c'est pas suffisant.

`terraform plan`

```sh
module.docker_wordpress.null_resource.ssh_target: Refreshing state... [id=5867348079461281823]
module.docker_install.null_resource.ssh_target: Refreshing state... [id=1109116924981371443]
module.docker_run.null_resource.ssh_target: Refreshing state... [id=5231299053336184424]
module.docker_run.docker_volume.timkeyvol: Refreshing state... [id=myvol2]
module.docker_wordpress.docker_network.wordpress: Refreshing state... [id=782937cf7effe79d6333decc7f41450a53fa5fae08bd96ff10cf78ef7731682a]
module.docker_wordpress.data.docker_registry_image.mysql: Reading...
module.docker_run.docker_network.tim: Refreshing state... [id=149d52ed3c11054f5156e7cc7c3b55f2b44361599bac5a8245826cb04c94c13d]
module.docker_wordpress.data.docker_registry_image.wordpress: Reading...
module.docker_run.data.docker_registry_image.dockerhub: Reading...
module.docker_wordpress.docker_volume.db_data: Refreshing state... [id=db_data]
module.docker_run.docker_image.nginx: Refreshing state... [id=sha256:dde0cca083bc75a0af14262b1469b5141284b4399a62fef923ec0c0e3b21f5bcnginx:latest]
module.docker_run.data.docker_registry_image.dockerhub: Read complete after 0s [id=sha256:78410999ff139c44af012ebee21a66d628d6f9ace7a353d4c6420e0e4a3ec6d1]
module.docker_wordpress.data.docker_registry_image.mysql: Read complete after 0s [id=sha256:4bc6bc963e6d8443453676cae56536f4b8156d78bae03c0145cbe47c2aad73bb]
module.docker_run.docker_image.terfock: Refreshing state... [id=sha256:0923cb22388fa33be72557c65a1b96bdd561e632d350c8527297cedcd4281dd3tim053692/terfock:1.0]
module.docker_wordpress.data.docker_registry_image.wordpress: Read complete after 0s [id=sha256:ed203a8f4ac1136558a4e14e4f920f11c1d7999658fb4c3610d425632d3010c5]
module.docker_wordpress.docker_container.db: Refreshing state... [id=9a262c0d744517285cdd471bfbc0371e53f7ff16eae4d2ef5bc332d2eb7c14f1]
module.docker_run.docker_container.nginx: Refreshing state... [id=a8e3d4a1dc897b170d83d1aa63b4efcd14c00bd3eee563a2d9f3b02e712e9bcf]
module.docker_wordpress.docker_container.wordpress: Refreshing state... [id=320669c31bcff5ec6f172d749b465784610824370f06b0d00050c6f2883bad3e]

Terraform used the selected providers to generate the following execution plan. Resource actions are
indicated with the following symbols:
  + create
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # module.docker_run.docker_container.nginx must be replaced
-/+ resource "docker_container" "nginx" {
      + bridge                                      = (known after apply)
      ~ command                                     = [
          - "nginx",
          - "-g",
          - "daemon off;",
        ] -> (known after apply)
      + container_logs                              = (known after apply)
      - cpu_shares                                  = 0 -> null
      - dns                                         = [] -> null
      - dns_opts                                    = [] -> null
      - dns_search                                  = [] -> null
      ~ entrypoint                                  = [
          - "/docker-entrypoint.sh",
        ] -> (known after apply)
      ~ env                                         = [] -> (known after apply)
      + exit_code                                   = (known after apply)
      ~ gateway                                     = "177.22.0.1" -> (known after apply)
      - group_add                                   = [] -> null
      ~ hostname                                    = "a8e3d4a1dc89" -> (known after apply)
      ~ id                                          = "a8e3d4a1dc897b170d83d1aa63b4efcd14c00bd3eee563a2d9f3b02e712e9bcf" -> (known after apply)
      ~ init                                        = false -> (known after apply)
      ~ ip_address                                  = "177.22.0.2" -> (known after apply)
      ~ ip_prefix_length                            = 24 -> (known after apply)
      ~ ipc_mode                                    = "private" -> (known after apply)
      - links                                       = [] -> null
      ~ log_driver                                  = "json-file" -> (known after apply)
      - log_opts                                    = {} -> null
      - max_retry_count                             = 0 -> null
      - memory                                      = 0 -> null
      - memory_swap                                 = 0 -> null
        name                                        = "enginecks"
      ~ network_data                                = [
          - {
              - gateway                   = "177.22.0.1"
              - global_ipv6_prefix_length = 0
              - ip_address                = "177.22.0.2"
              - ip_prefix_length          = 24
              - network_name              = "mynet"
                # (2 unchanged attributes hidden)
            },
        ] -> (known after apply)
      - network_mode                                = "bridge" -> null # forces replacement
      - privileged                                  = false -> null
      - publish_all_ports                           = false -> null
      ~ runtime                                     = "runc" -> (known after apply)
      ~ security_opts                               = [] -> (known after apply)
      ~ shm_size                                    = 64 -> (known after apply)
      ~ stop_signal                                 = "SIGQUIT" -> (known after apply)
      ~ stop_timeout                                = 0 -> (known after apply)
      - storage_opts                                = {} -> null
      - sysctls                                     = {} -> null
      - tmpfs                                       = {} -> null
        # (20 unchanged attributes hidden)

      - volumes {
          - container_path = "/usr/share/nginx/html/" -> null
          - read_only      = false -> null
          - volume_name    = "myvol2" -> null
            # (2 unchanged attributes hidden)
        }
      + volumes {
          + container_path = "/usr/share/nginx/html/"
          + volume_name    = "myvol2"
            # (2 unchanged attributes hidden)
        }

        # (2 unchanged blocks hidden)
    }

  # module.docker_wordpress.docker_container.db must be replaced
-/+ resource "docker_container" "db" {
      + bridge                                      = (known after apply)
      ~ command                                     = [
          - "mysqld",
        ] -> (known after apply)
      + container_logs                              = (known after apply)
      - cpu_shares                                  = 0 -> null
      - dns                                         = [] -> null
      - dns_opts                                    = [] -> null
      - dns_search                                  = [] -> null
      ~ entrypoint                                  = [
          - "docker-entrypoint.sh",
        ] -> (known after apply)
      + exit_code                                   = (known after apply)
      ~ gateway                                     = "172.18.0.1" -> (known after apply)
      - group_add                                   = [] -> null
      ~ hostname                                    = "9a262c0d7445" -> (known after apply)
      ~ id                                          = "9a262c0d744517285cdd471bfbc0371e53f7ff16eae4d2ef5bc332d2eb7c14f1" -> (known after apply)
      ~ image                                       = "sha256:5107333e08a87b836d48ff7528b1e84b9c86781cc9f1748bbc1b8c42a870d933" -> "docker_image.mysql.name" # forces replacement
      ~ init                                        = false -> (known after apply)
      ~ ip_address                                  = "172.18.0.2" -> (known after apply)
      ~ ip_prefix_length                            = 16 -> (known after apply)
      ~ ipc_mode                                    = "private" -> (known after apply)
      - links                                       = [] -> null
      ~ log_driver                                  = "json-file" -> (known after apply)
      - log_opts                                    = {} -> null
      - max_retry_count                             = 0 -> null
      - memory                                      = 0 -> null
      - memory_swap                                 = 0 -> null
        name                                        = "db"
      ~ network_data                                = [
          - {
              - gateway                   = "172.18.0.1"
              - global_ipv6_prefix_length = 0
              - ip_address                = "172.18.0.2"
              - ip_prefix_length          = 16
              - network_name              = "wordpress_net"
                # (2 unchanged attributes hidden)
            },
        ] -> (known after apply)
      - network_mode                                = "bridge" -> null # forces replacement
      - privileged                                  = false -> null
      - publish_all_ports                           = false -> null
      ~ runtime                                     = "runc" -> (known after apply)
      ~ security_opts                               = [] -> (known after apply)
      ~ shm_size                                    = 64 -> (known after apply)
      + stop_signal                                 = (known after apply)
      ~ stop_timeout                                = 0 -> (known after apply)
      - storage_opts                                = {} -> null
      - sysctls                                     = {} -> null
      - tmpfs                                       = {} -> null
        # (20 unchanged attributes hidden)

      - volumes {
          - container_path = "/var/lib/mysql/" -> null
          - host_path      = "/srv/wordpress/" -> null
          - read_only      = false -> null
          - volume_name    = "db_data" -> null
            # (1 unchanged attribute hidden)
        }
      + volumes {
          + container_path = "/var/lib/mysql/"
          + host_path      = "/srv/wordpress/"
          + volume_name    = "db_data"
            # (1 unchanged attribute hidden)
        }

        # (1 unchanged block hidden)
    }

  # module.docker_wordpress.docker_container.wordpress must be replaced
-/+ resource "docker_container" "wordpress" {
      + bridge                                      = (known after apply)
      ~ command                                     = [
          - "apache2-foreground",
        ] -> (known after apply)
      + container_logs                              = (known after apply)
      - cpu_shares                                  = 0 -> null
      - dns                                         = [] -> null
      - dns_opts                                    = [] -> null
      - dns_search                                  = [] -> null
      ~ entrypoint                                  = [
          - "docker-entrypoint.sh",
        ] -> (known after apply)
      + exit_code                                   = (known after apply)
      ~ gateway                                     = "172.18.0.1" -> (known after apply)
      - group_add                                   = [] -> null
      ~ hostname                                    = "320669c31bcf" -> (known after apply)
      ~ id                                          = "320669c31bcff5ec6f172d749b465784610824370f06b0d00050c6f2883bad3e" -> (known after apply)
      ~ image                                       = "sha256:372ef0d81712bd1fbcaa3aff6a207409a26666bf5330c100f340d9d3a8cac6c7" -> "docker_image.wordpress.name" # forces replacement
      ~ init                                        = false -> (known after apply)
      ~ ip_address                                  = "172.18.0.3" -> (known after apply)
      ~ ip_prefix_length                            = 16 -> (known after apply)
      ~ ipc_mode                                    = "private" -> (known after apply)
      - links                                       = [] -> null
      ~ log_driver                                  = "json-file" -> (known after apply)
      - log_opts                                    = {} -> null
      - max_retry_count                             = 0 -> null
      - memory                                      = 0 -> null
      - memory_swap                                 = 0 -> null
        name                                        = "wordpress"
      ~ network_data                                = [
          - {
              - gateway                   = "172.18.0.1"
              - global_ipv6_prefix_length = 0
              - ip_address                = "172.18.0.3"
              - ip_prefix_length          = 16
              - network_name              = "wordpress_net"
                # (2 unchanged attributes hidden)
            },
        ] -> (known after apply)
      - network_mode                                = "bridge" -> null # forces replacement
      - privileged                                  = false -> null
      - publish_all_ports                           = false -> null
      ~ runtime                                     = "runc" -> (known after apply)
      ~ security_opts                               = [] -> (known after apply)
      ~ shm_size                                    = 64 -> (known after apply)
      ~ stop_signal                                 = "SIGWINCH" -> (known after apply)
      ~ stop_timeout                                = 0 -> (known after apply)
      - storage_opts                                = {} -> null
      - sysctls                                     = {} -> null
      - tmpfs                                       = {} -> null
      - working_dir                                 = "/var/www/html" -> null
        # (19 unchanged attributes hidden)

        # (2 unchanged blocks hidden)
    }

  # module.docker_wordpress.docker_image.mysql will be created
  + resource "docker_image" "mysql" {
      + id            = (known after apply)
      + image_id      = (known after apply)
      + latest        = (known after apply)
      + name          = "mysql:5.7"
      + output        = (known after apply)
      + pull_triggers = [
          + "sha256:4bc6bc963e6d8443453676cae56536f4b8156d78bae03c0145cbe47c2aad73bb",
        ]
      + repo_digest   = (known after apply)
    }

  # module.docker_wordpress.docker_image.wordpress will be created
  + resource "docker_image" "wordpress" {
      + id            = (known after apply)
      + image_id      = (known after apply)
      + latest        = (known after apply)
      + name          = "wordpress:latest"
      + output        = (known after apply)
      + pull_triggers = [
          + "sha256:ed203a8f4ac1136558a4e14e4f920f11c1d7999658fb4c3610d425632d3010c5",
        ]
      + repo_digest   = (known after apply)
    }

Plan: 5 to add, 0 to change, 3 to destroy.

Changes to Outputs:
  ~ docker_ip_db            = "172.18.0.2" -> (known after apply)
  ~ docker_ip_wordpress     = "172.18.0.3" -> (known after apply)
╷
│ Warning: Deprecated attribute
│ 
│   on modules/docker_run/main.tf line 63, in resource "docker_container" "nginx":
│   63:     image = docker_image.nginx.latest
│ 
│ The attribute "latest" is deprecated. Refer to the provider documentation for details.
│ 
│ (and 7 more similar warnings elsewhere)
╵

────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly
these actions if you run "terraform apply" now.
```

`terraform apply -auto-approve`

```sh
module.docker_run.null_resource.ssh_target: Refreshing state... [id=5231299053336184424]
module.docker_wordpress.null_resource.ssh_target: Refreshing state... [id=5867348079461281823]
module.docker_install.null_resource.ssh_target: Refreshing state... [id=1109116924981371443]
module.docker_wordpress.data.docker_registry_image.wordpress: Reading...
module.docker_wordpress.data.docker_registry_image.mysql: Reading...
module.docker_wordpress.docker_volume.db_data: Refreshing state... [id=db_data]
module.docker_wordpress.docker_network.wordpress: Refreshing state... [id=782937cf7effe79d6333decc7f41450a53fa5fae08bd96ff10cf78ef7731682a]
module.docker_run.data.docker_registry_image.dockerhub: Reading...
module.docker_run.docker_volume.timkeyvol: Refreshing state... [id=myvol2]
module.docker_run.docker_network.tim: Refreshing state... [id=149d52ed3c11054f5156e7cc7c3b55f2b44361599bac5a8245826cb04c94c13d]
module.docker_run.docker_image.nginx: Refreshing state... [id=sha256:dde0cca083bc75a0af14262b1469b5141284b4399a62fef923ec0c0e3b21f5bcnginx:latest]
module.docker_run.data.docker_registry_image.dockerhub: Read complete after 1s [id=sha256:78410999ff139c44af012ebee21a66d628d6f9ace7a353d4c6420e0e4a3ec6d1]
module.docker_run.docker_image.terfock: Refreshing state... [id=sha256:0923cb22388fa33be72557c65a1b96bdd561e632d350c8527297cedcd4281dd3tim053692/terfock:1.0]
module.docker_wordpress.data.docker_registry_image.mysql: Read complete after 1s [id=sha256:4bc6bc963e6d8443453676cae56536f4b8156d78bae03c0145cbe47c2aad73bb]
module.docker_wordpress.docker_image.mysql: Refreshing state... [id=sha256:5107333e08a87b836d48ff7528b1e84b9c86781cc9f1748bbc1b8c42a870d933mysql:5.7]
module.docker_wordpress.data.docker_registry_image.wordpress: Read complete after 1s [id=sha256:ed203a8f4ac1136558a4e14e4f920f11c1d7999658fb4c3610d425632d3010c5]
module.docker_wordpress.docker_image.wordpress: Refreshing state... [id=sha256:372ef0d81712bd1fbcaa3aff6a207409a26666bf5330c100f340d9d3a8cac6c7wordpress:latest]
module.docker_run.docker_container.nginx: Refreshing state... [id=ce4fc91f968a3f1887dc413bdf217c03296b3adbe3b9ab199ed442e5fabbfdcc]

Terraform used the selected providers to generate the following execution plan. Resource actions are
indicated with the following symbols:
  + create
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # module.docker_run.docker_container.nginx must be replaced
-/+ resource "docker_container" "nginx" {
      + bridge                                      = (known after apply)
      ~ command                                     = [
          - "nginx",
          - "-g",
          - "daemon off;",
        ] -> (known after apply)
      + container_logs                              = (known after apply)
      - cpu_shares                                  = 0 -> null
      - dns                                         = [] -> null
      - dns_opts                                    = [] -> null
      - dns_search                                  = [] -> null
      ~ entrypoint                                  = [
          - "/docker-entrypoint.sh",
        ] -> (known after apply)
      ~ env                                         = [] -> (known after apply)
      + exit_code                                   = (known after apply)
      ~ gateway                                     = "177.22.0.1" -> (known after apply)
      - group_add                                   = [] -> null
      ~ hostname                                    = "ce4fc91f968a" -> (known after apply)
      ~ id                                          = "ce4fc91f968a3f1887dc413bdf217c03296b3adbe3b9ab199ed442e5fabbfdcc" -> (known after apply)
      ~ init                                        = false -> (known after apply)
      ~ ip_address                                  = "177.22.0.2" -> (known after apply)
      ~ ip_prefix_length                            = 24 -> (known after apply)
      ~ ipc_mode                                    = "private" -> (known after apply)
      - links                                       = [] -> null
      ~ log_driver                                  = "json-file" -> (known after apply)
      - log_opts                                    = {} -> null
      - max_retry_count                             = 0 -> null
      - memory                                      = 0 -> null
      - memory_swap                                 = 0 -> null
        name                                        = "enginecks"
      ~ network_data                                = [
          - {
              - gateway                   = "177.22.0.1"
              - global_ipv6_prefix_length = 0
              - ip_address                = "177.22.0.2"
              - ip_prefix_length          = 24
              - network_name              = "mynet"
                # (2 unchanged attributes hidden)
            },
        ] -> (known after apply)
      - network_mode                                = "bridge" -> null # forces replacement
      - privileged                                  = false -> null
      - publish_all_ports                           = false -> null
      ~ runtime                                     = "runc" -> (known after apply)
      ~ security_opts                               = [] -> (known after apply)
      ~ shm_size                                    = 64 -> (known after apply)
      ~ stop_signal                                 = "SIGQUIT" -> (known after apply)
      ~ stop_timeout                                = 0 -> (known after apply)
      - storage_opts                                = {} -> null
      - sysctls                                     = {} -> null
      - tmpfs                                       = {} -> null
        # (20 unchanged attributes hidden)

      - volumes {
          - container_path = "/usr/share/nginx/html/" -> null
          - read_only      = false -> null
          - volume_name    = "myvol2" -> null
            # (2 unchanged attributes hidden)
        }
      + volumes {
          + container_path = "/usr/share/nginx/html/"
          + volume_name    = "myvol2"
            # (2 unchanged attributes hidden)
        }

        # (2 unchanged blocks hidden)
    }

  # module.docker_wordpress.docker_container.db will be created
  + resource "docker_container" "db" {
      + attach                                      = false
      + bridge                                      = (known after apply)
      + command                                     = (known after apply)
      + container_logs                              = (known after apply)
      + container_read_refresh_timeout_milliseconds = 15000
      + entrypoint                                  = (known after apply)
      + env                                         = [
          + "MYSQL_DATABASE=wordpress",
          + "MYSQL_PASSWORD=wordpress",
          + "MYSQL_ROOT_PASSWORD=wordpress",
          + "MYSQL_USER=wordpress",
        ]
      + exit_code                                   = (known after apply)
      + gateway                                     = (known after apply)
      + hostname                                    = (known after apply)
      + id                                          = (known after apply)
      + image                                       = "mysql:5.7"
      + init                                        = (known after apply)
      + ip_address                                  = (known after apply)
      + ip_prefix_length                            = (known after apply)
      + ipc_mode                                    = (known after apply)
      + log_driver                                  = (known after apply)
      + logs                                        = false
      + must_run                                    = true
      + name                                        = "db"
      + network_data                                = (known after apply)
      + read_only                                   = false
      + remove_volumes                              = true
      + restart                                     = "always"
      + rm                                          = false
      + runtime                                     = (known after apply)
      + security_opts                               = (known after apply)
      + shm_size                                    = (known after apply)
      + start                                       = true
      + stdin_open                                  = false
      + stop_signal                                 = (known after apply)
      + stop_timeout                                = (known after apply)
      + tty                                         = false
      + wait                                        = false
      + wait_timeout                                = 60

      + networks_advanced {
          + aliases      = []
          + name         = "wordpress_net"
            # (2 unchanged attributes hidden)
        }

      + volumes {
          + container_path = "/var/lib/mysql/"
          + host_path      = "/srv/wordpress/"
          + volume_name    = "db_data"
            # (1 unchanged attribute hidden)
        }
    }

  # module.docker_wordpress.docker_container.wordpress will be created
  + resource "docker_container" "wordpress" {
      + attach                                      = false
      + bridge                                      = (known after apply)
      + command                                     = (known after apply)
      + container_logs                              = (known after apply)
      + container_read_refresh_timeout_milliseconds = 15000
      + entrypoint                                  = (known after apply)
      + env                                         = [
          + "WORDPRESS_DB_HOST=db:3306",
          + "WORDPRESS_DB_PASSWORD=wordpress",
        ]
      + exit_code                                   = (known after apply)
      + gateway                                     = (known after apply)
      + hostname                                    = (known after apply)
      + id                                          = (known after apply)
      + image                                       = "wordpress:latest"
      + init                                        = (known after apply)
      + ip_address                                  = (known after apply)
      + ip_prefix_length                            = (known after apply)
      + ipc_mode                                    = (known after apply)
      + log_driver                                  = (known after apply)
      + logs                                        = false
      + must_run                                    = true
      + name                                        = "wordpress"
      + network_data                                = (known after apply)
      + read_only                                   = false
      + remove_volumes                              = true
      + restart                                     = "always"
      + rm                                          = false
      + runtime                                     = (known after apply)
      + security_opts                               = (known after apply)
      + shm_size                                    = (known after apply)
      + start                                       = true
      + stdin_open                                  = false
      + stop_signal                                 = (known after apply)
      + stop_timeout                                = (known after apply)
      + tty                                         = false
      + wait                                        = false
      + wait_timeout                                = 60

      + networks_advanced {
          + aliases      = []
          + name         = "wordpress_net"
            # (2 unchanged attributes hidden)
        }

      + ports {
          + external = 8080
          + internal = 80
          + ip       = "0.0.0.0"
          + protocol = "tcp"
        }
    }

Plan: 3 to add, 0 to change, 1 to destroy.

Changes to Outputs:
  ~ docker_ip_db            = "172.18.0.2" -> (known after apply)
  ~ docker_ip_wordpress     = "172.18.0.3" -> (known after apply)
module.docker_run.docker_container.nginx: Destroying... [id=ce4fc91f968a3f1887dc413bdf217c03296b3adbe3b9ab199ed442e5fabbfdcc]
module.docker_wordpress.docker_container.db: Creating...
module.docker_wordpress.docker_container.wordpress: Creating...
module.docker_run.docker_container.nginx: Destruction complete after 4s
module.docker_run.docker_container.nginx: Creating...
module.docker_wordpress.docker_container.db: Creation complete after 10s [id=463a9700b206be2a9cbedc6b8636505e19b132061a865b8d31483ac50c39f25b]
module.docker_wordpress.docker_container.wordpress: Still creating... [10s elapsed]
module.docker_wordpress.docker_container.wordpress: Creation complete after 11s [id=5cad2fc9e21a6838e8cd14e36943e9eb8153fea97d61f560da88b45c68b2a613]
module.docker_run.docker_container.nginx: Creation complete after 8s [id=7aa889bc7dc7d8c8594c158a78544602213db35b7de72b96a2a4578d87af1b50]
╷
│ Warning: Deprecated attribute
│ 
│   on modules/docker_run/main.tf line 63, in resource "docker_container" "nginx":
│   63:     image = docker_image.nginx.latest
│ 
│ The attribute "latest" is deprecated. Refer to the provider documentation for details.
│ 
│ (and 11 more similar warnings elsewhere)
╵

Apply complete! Resources: 3 added, 0 changed, 1 destroyed.

Outputs:

docker_ip_db = "172.18.0.2"
docker_ip_wordpress = "172.18.0.3"
docker_wordpress_volume = "/srv/wordpress/"
```

On va fermer les yeux.

Si je fais un terraform plan.

Malgré la modif, il supprime et recrée les 2 conteneurs. Car il ne faut pas se baser sur le nom concernant l'image. Mais sur un attribut qui s'appelle latest. qui correspond au sha_256.

```th
resource "docker_container" "db" {
    name = "db"
    image = docker_image.mysql.latest
    [...]
}
```

```th
resource "docker_container" "wordpress" {
    name = "wordpress"
    image = docker_image.wordpress.latest
    [...]
}
```

Si on fait un `terraform plan`

```sh
odule.docker_wordpress.null_resource.ssh_target: Refreshing state... [id=5867348079461281823]
module.docker_run.null_resource.ssh_target: Refreshing state... [id=5231299053336184424]
module.docker_install.null_resource.ssh_target: Refreshing state... [id=1109116924981371443]
module.docker_run.data.docker_registry_image.dockerhub: Reading...
module.docker_run.docker_image.nginx: Refreshing state... [id=sha256:dde0cca083bc75a0af14262b1469b5141284b4399a62fef923ec0c0e3b21f5bcnginx:latest]
module.docker_run.docker_network.tim: Refreshing state... [id=149d52ed3c11054f5156e7cc7c3b55f2b44361599bac5a8245826cb04c94c13d]
module.docker_run.docker_volume.timkeyvol: Refreshing state... [id=myvol2]
module.docker_wordpress.data.docker_registry_image.mysql: Reading...
module.docker_wordpress.docker_volume.db_data: Refreshing state... [id=db_data]
module.docker_wordpress.data.docker_registry_image.wordpress: Reading...
module.docker_wordpress.docker_network.wordpress: Refreshing state... [id=782937cf7effe79d6333decc7f41450a53fa5fae08bd96ff10cf78ef7731682a]
module.docker_wordpress.data.docker_registry_image.wordpress: Read complete after 1s [id=sha256:ed203a8f4ac1136558a4e14e4f920f11c1d7999658fb4c3610d425632d3010c5]
module.docker_wordpress.docker_image.wordpress: Refreshing state... [id=sha256:372ef0d81712bd1fbcaa3aff6a207409a26666bf5330c100f340d9d3a8cac6c7wordpress:latest]
module.docker_run.data.docker_registry_image.dockerhub: Read complete after 1s [id=sha256:78410999ff139c44af012ebee21a66d628d6f9ace7a353d4c6420e0e4a3ec6d1]
module.docker_run.docker_image.terfock: Refreshing state... [id=sha256:0923cb22388fa33be72557c65a1b96bdd561e632d350c8527297cedcd4281dd3tim053692/terfock:1.0]
module.docker_wordpress.data.docker_registry_image.mysql: Read complete after 1s [id=sha256:4bc6bc963e6d8443453676cae56536f4b8156d78bae03c0145cbe47c2aad73bb]
module.docker_wordpress.docker_image.mysql: Refreshing state... [id=sha256:5107333e08a87b836d48ff7528b1e84b9c86781cc9f1748bbc1b8c42a870d933mysql:5.7]
module.docker_run.docker_container.nginx: Refreshing state... [id=7aa889bc7dc7d8c8594c158a78544602213db35b7de72b96a2a4578d87af1b50]
module.docker_wordpress.docker_container.wordpress: Refreshing state... [id=5cad2fc9e21a6838e8cd14e36943e9eb8153fea97d61f560da88b45c68b2a613]
module.docker_wordpress.docker_container.db: Refreshing state... [id=463a9700b206be2a9cbedc6b8636505e19b132061a865b8d31483ac50c39f25b]

Terraform used the selected providers to generate the following execution plan. Resource actions are
indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # module.docker_run.docker_container.nginx must be replaced
-/+ resource "docker_container" "nginx" {
      + bridge                                      = (known after apply)
      ~ command                                     = [
          - "nginx",
          - "-g",
          - "daemon off;",
        ] -> (known after apply)
      + container_logs                              = (known after apply)
      - cpu_shares                                  = 0 -> null
      - dns                                         = [] -> null
      - dns_opts                                    = [] -> null
      - dns_search                                  = [] -> null
      ~ entrypoint                                  = [
          - "/docker-entrypoint.sh",
        ] -> (known after apply)
      ~ env                                         = [] -> (known after apply)
      + exit_code                                   = (known after apply)
      ~ gateway                                     = "177.22.0.1" -> (known after apply)
      - group_add                                   = [] -> null
      ~ hostname                                    = "7aa889bc7dc7" -> (known after apply)
      ~ id                                          = "7aa889bc7dc7d8c8594c158a78544602213db35b7de72b96a2a4578d87af1b50" -> (known after apply)
      ~ init                                        = false -> (known after apply)
      ~ ip_address                                  = "177.22.0.2" -> (known after apply)
      ~ ip_prefix_length                            = 24 -> (known after apply)
      ~ ipc_mode                                    = "private" -> (known after apply)
      - links                                       = [] -> null
      ~ log_driver                                  = "json-file" -> (known after apply)
      - log_opts                                    = {} -> null
      - max_retry_count                             = 0 -> null
      - memory                                      = 0 -> null
      - memory_swap                                 = 0 -> null
        name                                        = "enginecks"
      ~ network_data                                = [
          - {
              - gateway                   = "177.22.0.1"
              - global_ipv6_prefix_length = 0
              - ip_address                = "177.22.0.2"
              - ip_prefix_length          = 24
              - network_name              = "mynet"
                # (2 unchanged attributes hidden)
            },
        ] -> (known after apply)
      - network_mode                                = "bridge" -> null # forces replacement
      - privileged                                  = false -> null
      - publish_all_ports                           = false -> null
      ~ runtime                                     = "runc" -> (known after apply)
      ~ security_opts                               = [] -> (known after apply)
      ~ shm_size                                    = 64 -> (known after apply)
      ~ stop_signal                                 = "SIGQUIT" -> (known after apply)
      ~ stop_timeout                                = 0 -> (known after apply)
      - storage_opts                                = {} -> null
      - sysctls                                     = {} -> null
      - tmpfs                                       = {} -> null
        # (20 unchanged attributes hidden)

      - volumes {
          - container_path = "/usr/share/nginx/html/" -> null
          - read_only      = false -> null
          - volume_name    = "myvol2" -> null
            # (2 unchanged attributes hidden)
        }
      + volumes {
          + container_path = "/usr/share/nginx/html/"
          + volume_name    = "myvol2"
            # (2 unchanged attributes hidden)
        }

        # (2 unchanged blocks hidden)
    }

  # module.docker_wordpress.docker_container.db must be replaced
-/+ resource "docker_container" "db" {
      + bridge                                      = (known after apply)
      ~ command                                     = [
          - "mysqld",
        ] -> (known after apply)
      + container_logs                              = (known after apply)
      - cpu_shares                                  = 0 -> null
      - dns                                         = [] -> null
      - dns_opts                                    = [] -> null
      - dns_search                                  = [] -> null
      ~ entrypoint                                  = [
          - "docker-entrypoint.sh",
        ] -> (known after apply)
      + exit_code                                   = (known after apply)
      ~ gateway                                     = "172.18.0.1" -> (known after apply)
      - group_add                                   = [] -> null
      ~ hostname                                    = "463a9700b206" -> (known after apply)
      ~ id                                          = "463a9700b206be2a9cbedc6b8636505e19b132061a865b8d31483ac50c39f25b" -> (known after apply)
      ~ init                                        = false -> (known after apply)
      ~ ip_address                                  = "172.18.0.2" -> (known after apply)
      ~ ip_prefix_length                            = 16 -> (known after apply)
      ~ ipc_mode                                    = "private" -> (known after apply)
      - links                                       = [] -> null
      ~ log_driver                                  = "json-file" -> (known after apply)
      - log_opts                                    = {} -> null
      - max_retry_count                             = 0 -> null
      - memory                                      = 0 -> null
      - memory_swap                                 = 0 -> null
        name                                        = "db"
      ~ network_data                                = [
          - {
              - gateway                   = "172.18.0.1"
              - global_ipv6_prefix_length = 0
              - ip_address                = "172.18.0.2"
              - ip_prefix_length          = 16
              - network_name              = "wordpress_net"
                # (2 unchanged attributes hidden)
            },
        ] -> (known after apply)
      - network_mode                                = "bridge" -> null # forces replacement
      - privileged                                  = false -> null
      - publish_all_ports                           = false -> null
      ~ runtime                                     = "runc" -> (known after apply)
      ~ security_opts                               = [] -> (known after apply)
      ~ shm_size                                    = 64 -> (known after apply)
      + stop_signal                                 = (known after apply)
      ~ stop_timeout                                = 0 -> (known after apply)
      - storage_opts                                = {} -> null
      - sysctls                                     = {} -> null
      - tmpfs                                       = {} -> null
        # (21 unchanged attributes hidden)

      - volumes {
          - container_path = "/var/lib/mysql/" -> null
          - host_path      = "/srv/wordpress/" -> null
          - read_only      = false -> null
          - volume_name    = "db_data" -> null
            # (1 unchanged attribute hidden)
        }
      + volumes {
          + container_path = "/var/lib/mysql/"
          + host_path      = "/srv/wordpress/"
          + volume_name    = "db_data"
            # (1 unchanged attribute hidden)
        }

        # (1 unchanged block hidden)
    }

  # module.docker_wordpress.docker_container.wordpress must be replaced
-/+ resource "docker_container" "wordpress" {
      + bridge                                      = (known after apply)
      ~ command                                     = [
          - "apache2-foreground",
        ] -> (known after apply)
      + container_logs                              = (known after apply)
      - cpu_shares                                  = 0 -> null
      - dns                                         = [] -> null
      - dns_opts                                    = [] -> null
      - dns_search                                  = [] -> null
      ~ entrypoint                                  = [
          - "docker-entrypoint.sh",
        ] -> (known after apply)
      + exit_code                                   = (known after apply)
      ~ gateway                                     = "172.18.0.1" -> (known after apply)
      - group_add                                   = [] -> null
      ~ hostname                                    = "5cad2fc9e21a" -> (known after apply)
      ~ id                                          = "5cad2fc9e21a6838e8cd14e36943e9eb8153fea97d61f560da88b45c68b2a613" -> (known after apply)
      ~ init                                        = false -> (known after apply)
      ~ ip_address                                  = "172.18.0.3" -> (known after apply)
      ~ ip_prefix_length                            = 16 -> (known after apply)
      ~ ipc_mode                                    = "private" -> (known after apply)
      - links                                       = [] -> null
      ~ log_driver                                  = "json-file" -> (known after apply)
      - log_opts                                    = {} -> null
      - max_retry_count                             = 0 -> null
      - memory                                      = 0 -> null
      - memory_swap                                 = 0 -> null
        name                                        = "wordpress"
      ~ network_data                                = [
          - {
              - gateway                   = "172.18.0.1"
              - global_ipv6_prefix_length = 0
              - ip_address                = "172.18.0.3"
              - ip_prefix_length          = 16
              - network_name              = "wordpress_net"
                # (2 unchanged attributes hidden)
            },
        ] -> (known after apply)
      - network_mode                                = "bridge" -> null # forces replacement
      - privileged                                  = false -> null
      - publish_all_ports                           = false -> null
      ~ runtime                                     = "runc" -> (known after apply)
      ~ security_opts                               = [] -> (known after apply)
      ~ shm_size                                    = 64 -> (known after apply)
      ~ stop_signal                                 = "SIGWINCH" -> (known after apply)
      ~ stop_timeout                                = 0 -> (known after apply)
      - storage_opts                                = {} -> null
      - sysctls                                     = {} -> null
      - tmpfs                                       = {} -> null
      - working_dir                                 = "/var/www/html" -> null
        # (20 unchanged attributes hidden)

        # (2 unchanged blocks hidden)
    }

Plan: 3 to add, 0 to change, 3 to destroy.

Changes to Outputs:
  ~ docker_ip_db            = "172.18.0.2" -> (known after apply)
  ~ docker_ip_wordpress     = "172.18.0.3" -> (known after apply)
╷
│ Warning: Deprecated attribute
│ 
│   on modules/docker_run/main.tf line 63, in resource "docker_container" "nginx":
│   63:     image = docker_image.nginx.latest
│ 
│ The attribute "latest" is deprecated. Refer to the provider documentation for details.
│ 
│ (and 11 more similar warnings elsewhere)
╵

────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly
these actions if you run "terraform apply" now.
```

Si on fait `.id`.

Maintenant il faut travailler le `working_dir`

```th
resource "docker_container" "wordpress" {
    name = "wordpress"
    image = docker_image.wordpress.latest
    restart = "always"
    working_dir = "/var/www/html"
    [...]
}
```

En ajoutant `working_dir` on a un replacement.

`terraform apply -auto-approve`

## Désormais il faut update le network_mode "Bridge" pour éviter les forces replacement

TODO

Mais après l'image évitera de replace.

On a vu comment fixer l'idempotence working_dir.
