# Chapitre 17 - Terraform Destroy & Local_Exec
Suppression des ressources gérées par le tfstate
`terraform destroy -target <resource|module>`

Exemple :
Nos conteneurs sont présent sur notre vm.

On va prendre la ressource docker_container wordpress du module docker_wordpress.

On va supprimer cette ressource.

Pour ça :

`terraform destroy -target module.docker_wordpress.docker_container.wordpress`

Si on fait ceci, on va cibler le conteneur wordpress et va proposer de le supprimer tout simplement.

On fait yes

Et enfin, il l'a supprimé.

```sh
module.docker_wordpress.data.docker_registry_image.wordpress: Reading...
module.docker_wordpress.docker_network.wordpress: Refreshing state... [id=782937cf7effe79d6333decc7f41450a53fa5fae08bd96ff10cf78ef7731682a]
module.docker_wordpress.data.docker_registry_image.wordpress: Read complete after 1s [id=sha256:ed203a8f4ac1136558a4e14e4f920f11c1d7999658fb4c3610d425632d3010c5]
module.docker_wordpress.docker_image.wordpress: Refreshing state... [id=sha256:372ef0d81712bd1fbcaa3aff6a207409a26666bf5330c100f340d9d3a8cac6c7wordpress:latest]
module.docker_wordpress.docker_container.wordpress: Refreshing state... [id=8d3b41bf815bf590605a1ebda399b6980548e92535b5811781d9dc00f55dd5a3]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated
with the following symbols:
  - destroy

Terraform will perform the following actions:

  # module.docker_wordpress.docker_container.wordpress will be destroyed
  - resource "docker_container" "wordpress" {
      - attach                                      = false -> null
      - command                                     = [
          - "apache2-foreground",
        ] -> null
      - container_read_refresh_timeout_milliseconds = 15000 -> null
      - cpu_shares                                  = 0 -> null
      - dns                                         = [] -> null
      - dns_opts                                    = [] -> null
      - dns_search                                  = [] -> null
      - entrypoint                                  = [
          - "docker-entrypoint.sh",
        ] -> null
      - env                                         = [
          - "WORDPRESS_DB_HOST=db:3306",
          - "WORDPRESS_DB_PASSWORD=wordpress",
        ] -> null
      - gateway                                     = "172.18.0.1" -> null
      - group_add                                   = [] -> null
      - hostname                                    = "8d3b41bf815b" -> null
      - id                                          = "8d3b41bf815bf590605a1ebda399b6980548e92535b5811781d9dc00f55dd5a3" -> null
      - image                                       = "sha256:372ef0d81712bd1fbcaa3aff6a207409a26666bf5330c100f340d9d3a8cac6c7" -> null
      - init                                        = false -> null
      - ip_address                                  = "172.18.0.3" -> null
      - ip_prefix_length                            = 16 -> null
      - ipc_mode                                    = "private" -> null
      - links                                       = [] -> null
      - log_driver                                  = "json-file" -> null
      - log_opts                                    = {} -> null
      - logs                                        = false -> null
      - max_retry_count                             = 0 -> null
      - memory                                      = 0 -> null
      - memory_swap                                 = 0 -> null
      - must_run                                    = true -> null
      - name                                        = "wordpress" -> null
      - network_data                                = [
          - {
              - gateway                   = "172.18.0.1"
              - global_ipv6_prefix_length = 0
              - ip_address                = "172.18.0.3"
              - ip_prefix_length          = 16
              - network_name              = "wordpress_net"
                # (2 unchanged attributes hidden)
            },
        ] -> null
      - network_mode                                = "bridge" -> null
      - privileged                                  = false -> null
      - publish_all_ports                           = false -> null
      - read_only                                   = false -> null
      - remove_volumes                              = true -> null
      - restart                                     = "always" -> null
      - rm                                          = false -> null
      - runtime                                     = "runc" -> null
      - security_opts                               = [] -> null
      - shm_size                                    = 64 -> null
      - start                                       = true -> null
      - stdin_open                                  = false -> null
      - stop_signal                                 = "SIGWINCH" -> null
      - stop_timeout                                = 0 -> null
      - storage_opts                                = {} -> null
      - sysctls                                     = {} -> null
      - tmpfs                                       = {} -> null
      - tty                                         = false -> null
      - wait                                        = false -> null
      - wait_timeout                                = 60 -> null
      - working_dir                                 = "/var/www/html" -> null
        # (6 unchanged attributes hidden)

      - networks_advanced {
          - aliases      = [] -> null
          - name         = "wordpress_net" -> null
            # (2 unchanged attributes hidden)
        }

      - ports {
          - external = 8080 -> null
          - internal = 80 -> null
          - ip       = "0.0.0.0" -> null
          - protocol = "tcp" -> null
        }
    }

Plan: 0 to add, 0 to change, 1 to destroy.
╷
│ Warning: Resource targeting is in effect
│ 
│ You are creating a plan with the -target option, which means that the result of this plan may not represent
│ all of the changes requested by the current configuration.
│ 
│ The -target option is not for routine use, and is provided only for exceptional situations such as
│ recovering from errors or mistakes, or when Terraform specifically suggests to use it as part of an error
│ message.
╵
╷
│ Warning: Deprecated attribute
│ 
│   on modules/docker_run/main.tf line 63, in resource "docker_container" "nginx":
│   63:     image = docker_image.nginx.latest
│ 
│ The attribute "latest" is deprecated. Refer to the provider documentation for details.
│ 
│ (and 5 more similar warnings elsewhere)
╵

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

module.docker_wordpress.docker_container.wordpress: Destroying... [id=8d3b41bf815bf590605a1ebda399b6980548e92535b5811781d9dc00f55dd5a3]
module.docker_wordpress.docker_container.wordpress: Destruction complete after 3s
╷
│ Warning: Applied changes may be incomplete
│ 
│ The plan was created with the -target option in effect, so some changes requested in the configuration may
│ have been ignored and the output values may not be fully updated. Run the following command to verify that
│ no other changes are pending:
│     terraform plan
│ 
│ Note that the -target option is not suitable for routine use, and is provided only for exceptional
│ situations such as recovering from errors or mistakes, or when Terraform specifically suggests to use it as
│ part of an error message.
╵

Destroy complete! Resources: 1 destroyed.
```

`terraform apply -target module.docker_wordpress.docker_container.wordpress`

On peut faire la même chose pour un module entier : `module.docker_wordpress`

`terraform destroy -target module.docker_wordpress`

Il supprime 7 éléments (volumes, networks, images, et tout ce qu'il n'est pas capable de gérer)

Si on souhaite supprimer 2 conteneurs associé à la même image, on peut pas supprimer une image si la seconde existe toujours.

docker ps
Plus de conteneur

docker images (Plus d'images en question)

target pour relancer l'intégralité.

Avant de refaire un destroy all

On va voir un deuxième élément.

On va pouvoir utiliser le when destroy
```
provisioner "local-exec" {
    when = destroy
    command = "echo 'tout cassé'"
}
```

## when destroy
On supprime le docker wordpress (timestamp - ip sur lequel c'est arrivé - Personne qui l'a fait) Histoire de tracer. C'est pas forcément la meilleure utilisation. Si on a une liste de nos instance fichier en local on peut modifie le fichier en local avec un sed -z pour supprimer la ligne qui correspond...

module wordpress main

Ajouter la ligne provisioner :

```th
provisioner "local-exec" {
    command = "echo '${timestamp()} | ${var.ssh_user}@${var.ssh_host} > init ${docker_container.wordpress.name}' >> traces.log"
}
provisioner "local-exec" {
    when = destroy
    command = "echo '${timestamp()} | ${var.ssh_user}@${var.ssh_host} > destroy ${docker_container.wordpress.name}   ' >> traces.log"
}
```

```sh
terraform destroy -target module.docker_wordpress.docker_container.wordpress
```

Cela retourne une erreur : on peut mentionner uniquement des éléments avec self. dans les destroy : 

```th
    provisioner "local-exec" {
        when = destroy
        command = "echo '${timestamp()} | ${var.ssh_user}@${var.ssh_host} > destroy ${self.name}' >> traces.log"
    }
```

## Attention
Cette méthode ne marche plus depuis une mise à jour.

```txt
Pour les personnes rencontrant des erreurs terraform destroy à cause des maj voici les étapes :

Ajouter une ressource au dessus du docker_container "wordpress" :

resource "local_file" "log_info" {
  content = <<EOF
timestamp=${timestamp()}
ssh_user=${var.ssh_user}
ssh_host=${var.ssh_host}
EOF

  filename = "${path.module}/log_info.txt"
}

  filename = "${path.module}/log_info.txt"
}

Créer 2 scripts :
#!/bin/bash
timestamp=$1
ssh_user=$2
ssh_host=$3
container_name=$4
echo "${timestamp} | ${ssh_user}@${ssh_host} > init ${container_name}" >> traces.log



destroy_log.sh
#!/bin/bash
timestamp=$1
ssh_user=$2
ssh_host=$3
container_name=$4
echo "${timestamp} | ${ssh_user}@${ssh_host} > destroy ${container_name}" >> traces.log


Les provisionneurs :

  provisioner "local-exec" {
    command = <<-EOT
      bash ${path.module}/init_log.sh $(awk -F= '/timestamp/ {print $2}' ${path.module}/log_info.txt) \
        $(awk -F= '/ssh_user/ {print $2}' ${path.module}/log_info.txt) \
        $(awk -F= '/ssh_host/ {print $2}' ${path.module}/log_info.txt) \
        ${self.name}
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      bash ${path.module}/destroy_log.sh $(awk -F= '/timestamp/ {print $2}' ${path.module}/log_info.txt) \
        $(awk -F= '/ssh_user/ {print $2}' ${path.module}/log_info.txt) \
        $(awk -F= '/ssh_host/ {print $2}' ${path.module}/log_info.txt) \
        ${self.name}
    EOT
  }

  filename = "${path.module}/log_info.txt"
}

Ne pas oublier le chmod +x des fichiers sh init & destroy
```

`terraform show` -> Pour regarder les attributs disponnibles

