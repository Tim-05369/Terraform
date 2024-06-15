# Variable & Local_exec : strings, listes et maps
On va manipuler les variables et découvrir le local_exec nous permettant de faire du terraform en local. C'est très sympa, c'est utilisable et utilisé en production quand on collecte des informations sur des éléments distant. Par exemple popé sur du cloud ou autre. On va pouvoir compiler les variables qu'on utilise pour localement pouvoir les réutiliser. On peut aussi utiliser le local-exec à distance sur une machine mais ça on verra ça plus tard.

Pour cela, `local-exec` et `remote-exec` permet de faire comme si on faisait des commandes ssh à distance. Comme un peu le fait ansible. Localexec c'est l'utilisation local sur la machine sur laquelle on est situé. On va utiliser donc remote-exec et local-exec qui sont des provisionners. Un provisionneur permet par exemple de lancer localement des commandes si on est sur une instance distance. Cela permet aussi de lancer des commandes local à notre machine terraform.

```txt
+- Utilisation de provisioner sur ces resources (passer des commandes) :
    > provisioner remote-exec : exécution sur la machine distante
    > provisioner local-exec : exécution sur la machine terraform

+- type de variables :
    > string
    > list
    > map
```

Ce tuto présente le cas d'utilisation le plus simple des variables dans un fichier.

Très rapidement

## String
Exemple string :
```
variable "str" {
    type = string
    default = "127.0.0.1 gitlab.test"
}

resource "null_resource" "model" {
    provisioner "local-exec" {
        command = "echo '${var.str}' > hosts.txt"
    }
}
```

Ce provisioner on va l'utiliser en localhost. On va pas le faire en local.

Du coup on utilise null_resource et dedans on utilise local-exec qui permet de faire tourner en local la commande echo variable pour créer un nouveau fichier hosts.txt sur la machine terraform.

On écrit ce code dans notre projet :

```
variable "str" {
    type = string
    default = "127.0.0.1 gitlab.test"
}

resource "null_resource" "model" {
    provisioner "local-exec" {
        command = "echo '${var.str}' > hosts.txt"
    }
}

output "str" {
    value = var.str
}
```

Vu qu'on est dans notre terraform on fait var.str (dans l'output)

Après update. Lancer `terraform init`.

Puis `terraform plan`

Le résultat :
```
Terraform used the selected providers to generate the
following execution plan. Resource actions are
indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # null_resource.model will be created
  + resource "null_resource" "model" {
      + id = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  - mavariable = "Hello World !!" -> null
  + str        = "127.0.0.1 gitlab.test"

───────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan,
so Terraform can't guarantee to take exactly these
actions if you run "terraform apply" now.
```

Lançon `terraform apply`

```
erraform used the selected providers to generate the
following execution plan. Resource actions are
indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # null_resource.model will be created
  + resource "null_resource" "model" {
      + id = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  - mavariable = "Hello World !!" -> null
  + str        = "127.0.0.1 gitlab.test"

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

null_resource.model: Creating...
null_resource.model: Provisioning with 'local-exec'...
null_resource.model (local-exec): Executing: ["/bin/sh" "-c" "echo '127.0.0.1 gitlab.test' > hosts.txt"]
null_resource.model: Creation complete after 0s [id=2209618468646120743]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

str = "127.0.0.1 gitlab.test"
```

Et la, on voit que notre hosts.txt a bien été implémenté.

## Map
Faisont maintenant une Map. Voici sa déclaration :
```tf
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
```

L'idéal ensuite c'est de faire un terraform destroy pour supprimer la ressource et recommencer de 0.

Le foreach boucle la valeur dans provisionner.

L'idempotence (Capacité du système à appliquer des modification et à ne pas rejouer des choses qui ont déjà été joué).

A la base, globalement, les orchestrateurs ne sont pas capable de voir s'il y a une différence ou pas dans les fichiers de destinations.

Normalement on passe par des template ou des modules spécifique de checksum pour vérifier si le fichier a été modifié etc... En l'occurance vu que c'est une commande brut de décoffrage. Terraform est incapable de voir la différence. Sa seule manière de voir la différence c'est par l'évolution de ses variables, de son contenu de main, descriptif et il va comparer tout ça à son tfstate et s'il y a une modification il va l'appliquer. En l'occurrance, comme son state ne contient pas le contenu du fichier host, il est incapable de faire la différence. C'est pour ça qu'on va supprimer le fichier. Finalement on aurait une modification malgré tout mais on ne ferait que empiler les éléments dans le fichiers Host.

Lançon donc un `terraform destroy` puis un `rm hosts.txt`.

```
null_resource.model: Refreshing state... [id=2209618468646120743]

Terraform used the selected providers to generate the
following execution plan. Resource actions are
indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # null_resource.model will be destroyed
  - resource "null_resource" "model" {
      - id = "2209618468646120743" -> null
    }

Plan: 0 to add, 0 to change, 1 to destroy.

Changes to Outputs:
  - str = "127.0.0.1 gitlab.test" -> null

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

null_resource.model: Destroying... [id=2209618468646120743]
null_resource.model: Destruction complete after 0s
```

Inséront maintenant le contenu cité précédemment dans main.tf.

Puis faisons un 
``` sh
terraform plan
```

Résultat :
```
Terraform used the selected providers to generate the
following execution plan. Resource actions are
indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # null_resource.hosts["127.0.0.1"] will be created
  + resource "null_resource" "hosts" {
      + id = (known after apply)
    }

  # null_resource.hosts["192.169.1.168"] will be created
  + resource "null_resource" "hosts" {
      + id = (known after apply)
    }

  # null_resource.hosts["192.169.1.170"] will be created
  + resource "null_resource" "hosts" {
      + id = (known after apply)
    }

Plan: 3 to add, 0 to change, 0 to destroy.

───────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan,
so Terraform can't guarantee to take exactly these
actions if you run "terraform apply" now.
```

On retrouve dedans nos 3 resource à créer.

Plus qu'à le faire avec le `terraform apply`.

```
Terraform used the selected providers to generate the
following execution plan. Resource actions are
indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # null_resource.hosts["127.0.0.1"] will be created
  + resource "null_resource" "hosts" {
      + id = (known after apply)
    }

  # null_resource.hosts["192.169.1.168"] will be created
  + resource "null_resource" "hosts" {
      + id = (known after apply)
    }

  # null_resource.hosts["192.169.1.170"] will be created
  + resource "null_resource" "hosts" {
      + id = (known after apply)
    }

Plan: 3 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

null_resource.hosts["127.0.0.1"]: Creating...
null_resource.hosts["192.169.1.168"]: Creating...
null_resource.hosts["192.169.1.170"]: Creating...
null_resource.hosts["192.169.1.170"]: Provisioning with 'local-exec'...
null_resource.hosts["127.0.0.1"]: Provisioning with 'local-exec'...
null_resource.hosts["192.169.1.168"]: Provisioning with 'local-exec'...
null_resource.hosts["192.169.1.170"] (local-exec): Executing: ["/bin/sh" "-c" "echo '192.169.1.170 prometheus.test' >> hosts.txt"]
null_resource.hosts["127.0.0.1"] (local-exec): Executing: ["/bin/sh" "-c" "echo '127.0.0.1 localhost gitlab.local' >> hosts.txt"]
null_resource.hosts["192.169.1.168"] (local-exec): Executing: ["/bin/sh" "-c" "echo '192.169.1.168 gitlab.test' >> hosts.txt"]
null_resource.hosts["192.169.1.168"]: Creation complete after 0s [id=7360921043659934714]
null_resource.hosts["127.0.0.1"]: Creation complete after 0s [id=3332246357530035658]
null_resource.hosts["192.169.1.170"]: Creation complete after 0s [id=5072415424503691076]
```

Et voilà, les modifications ont été faite. Si on affiche l'ensemble du fichier hosts.txt. On a bien nos 3 lignes.

```sh
cat hosts.txt
```

```
127.0.0.1 localhost gitlab.local
192.169.1.170 prometheus.test
192.169.1.168 gitlab.test
```

Modifions maintenant de nouveau hosts.txt en modifiant le contenu 127.0.0.1 par 127.0.0.2:

```tf
variable "hosts" {
    default = {
        "127.0.0.2" = "localhost gitlab.local"
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
```

```
terraform apply
```

```
null_resource.hosts["192.169.1.168"]: Refreshing state... [id=7360921043659934714]
null_resource.hosts["192.169.1.170"]: Refreshing state... [id=5072415424503691076]
null_resource.hosts["127.0.0.1"]: Refreshing state... [id=3332246357530035658]

Terraform used the selected providers to generate the
following execution plan. Resource actions are
indicated with the following symbols:
  + create
  - destroy

Terraform will perform the following actions:

  # null_resource.hosts["127.0.0.1"] will be destroyed
  # (because key ["127.0.0.1"] is not in for_each map)
  - resource "null_resource" "hosts" {
      - id = "3332246357530035658" -> null
    }

  # null_resource.hosts["127.0.0.2"] will be created
  + resource "null_resource" "hosts" {
      + id = (known after apply)
    }

Plan: 1 to add, 0 to change, 1 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

null_resource.hosts["127.0.0.1"]: Destroying... [id=3332246357530035658]
null_resource.hosts["127.0.0.1"]: Destruction complete after 0s
null_resource.hosts["127.0.0.2"]: Creating...
null_resource.hosts["127.0.0.2"]: Provisioning with 'local-exec'...
null_resource.hosts["127.0.0.2"] (local-exec): Executing: ["/bin/sh" "-c" "echo '127.0.0.2 localhost gitlab.local' >> hosts.txt"]
null_resource.hosts["127.0.0.2"]: Creation complete after 0s [id=1375006285980059641]
```

Il m'informe bien que ma modification a eu lieu, je confirm.

On check le fichier hosts.txt qu'on a pas supprimé.

```
cat hosts.txt
```

```
127.0.0.1 localhost gitlab.local
192.169.1.170 prometheus.test
192.169.1.168 gitlab.test
127.0.0.2 localhost gitlab.local
```

Et là on observe que finalement il a été rajouter la ligne et qu'il est incapable de lui-même de voir et de se dire que telle ligne il faut la drop. Elle n'a pas de raison d'exister.

Modifions encore le contenue de notre fichier en y ajoutant `gitlab.me`.

```

variable "hosts" {
    default = {
        "127.0.0.2" = "localhost gitlab.local gitlab.me"
        "192.169.1.168" = "gitlab.test"
        "192.169.1.170" = "prometheus.test"
    }
}

resource "null_resource" "hosts" {
    for_each = var.hosts
    triggers = {
        foo = each.value
    }
    provisioner "local-exec" {
        command = "echo '${each.key} ${each.value}' >> hosts.txt"
    }
}
```

```sh
terraform apply
```

Résultat : 
```
null_resource.hosts["192.169.1.168"]: Refreshing state... [id=7360921043659934714]
null_resource.hosts["192.169.1.170"]: Refreshing state... [id=5072415424503691076]
null_resource.hosts["127.0.0.2"]: Refreshing state... [id=1375006285980059641]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against
your configuration and found no differences, so no
changes are needed.

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```

Si on observe les résultats, on voit qu'en faisant une update de valeur et non pas de clé, on a pas d'exécutionbh de la part de terraform nous demandant de confirmer la modification.

## Trigger
Il existe en Terraform le trigger. 
On le place juste derrière notre foreach.

```
variable "hosts" {
    default = {
        "127.0.0.2" = "localhost gitlab.local gitlab.me"
        "192.169.1.168" = "gitlab.test"
        "192.169.1.170" = "prometheus.test"
    }
}
resource "null_resource" "hosts" {
    for_each = var.hosts
    triggers = {
        foo = each.value
    }
    provisioner "local-exec" {
        command = "echo '${each.key} ${each.value}' >> hosts.txt"
    }
}
```

avec ce trigger, tout se déclanchera quand il y aura une modification de valeur.

```sh
terraform apply
```

```
null_resource.hosts["127.0.0.2"]: Refreshing state... [id=1375006285980059641]
null_resource.hosts["192.169.1.170"]: Refreshing state... [id=5072415424503691076]
null_resource.hosts["192.169.1.168"]: Refreshing state... [id=7360921043659934714]

Terraform used the selected providers to generate the
following execution plan. Resource actions are
indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # null_resource.hosts["127.0.0.2"] must be replaced
-/+ resource "null_resource" "hosts" {
      ~ id       = "1375006285980059641" -> (known after apply)
      + triggers = { # forces replacement
          + "foo" = "localhost gitlab.local gitlab.me"
        }
    }

  # null_resource.hosts["192.169.1.168"] must be replaced
-/+ resource "null_resource" "hosts" {
      ~ id       = "7360921043659934714" -> (known after apply)
      + triggers = { # forces replacement
          + "foo" = "gitlab.test"
        }
    }

  # null_resource.hosts["192.169.1.170"] must be replaced
-/+ resource "null_resource" "hosts" {
      ~ id       = "5072415424503691076" -> (known after apply)
      + triggers = { # forces replacement
          + "foo" = "prometheus.test"
        }
    }

Plan: 3 to add, 0 to change, 3 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

null_resource.hosts["127.0.0.2"]: Destroying... [id=1375006285980059641]
null_resource.hosts["192.169.1.170"]: Destroying... [id=5072415424503691076]
null_resource.hosts["192.169.1.168"]: Destroying... [id=7360921043659934714]
null_resource.hosts["192.169.1.170"]: Destruction complete after 0s
null_resource.hosts["192.169.1.168"]: Destruction complete after 0s
null_resource.hosts["192.169.1.170"]: Creating...
null_resource.hosts["127.0.0.2"]: Destruction complete after 0s
null_resource.hosts["192.169.1.170"]: Provisioning with 'local-exec'...
null_resource.hosts["192.169.1.170"] (local-exec): Executing: ["/bin/sh" "-c" "echo '192.169.1.170 prometheus.test' >> hosts.txt"]
null_resource.hosts["192.169.1.170"]: Creation complete after 0s [id=4341223260810170799]
null_resource.hosts["127.0.0.2"]: Creating...
null_resource.hosts["192.169.1.168"]: Creating...
null_resource.hosts["192.169.1.168"]: Provisioning with 'local-exec'...
null_resource.hosts["127.0.0.2"]: Provisioning with 'local-exec'...
null_resource.hosts["127.0.0.2"] (local-exec): Executing: ["/bin/sh" "-c" "echo '127.0.0.2 localhost gitlab.local gitlab.me' >> hosts.txt"]
null_resource.hosts["192.169.1.168"] (local-exec): Executing: ["/bin/sh" "-c" "echo '192.169.1.168 gitlab.test' >> hosts.txt"]
null_resource.hosts["127.0.0.2"]: Creation complete after 0s [id=8775237600488870554]
null_resource.hosts["192.169.1.168"]: Creation complete after 0s [id=7815776584721952470]
```

Ajoutons comme valeur gitlab.tim par exemple.

Puis reexécuton 
```
terraform apply
```

On se rend compte que les modifs sont bien prise en compte en fonction des valeurs.

```
Terraform used the selected providers to generate the
following execution plan. Resource actions are
indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # null_resource.hosts["127.0.0.2"] must be replaced
-/+ resource "null_resource" "hosts" {
      ~ id       = "8775237600488870554" -> (known after apply)
      ~ triggers = { # forces replacement
          ~ "foo" = "localhost gitlab.local gitlab.me" -> "localhost gitlab.local gitlab.me gitlab.tim"
        }
    }

Plan: 1 to add, 0 to change, 1 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

null_resource.hosts["127.0.0.2"]: Destroying... [id=8775237600488870554]
null_resource.hosts["127.0.0.2"]: Destruction complete after 0s
null_resource.hosts["127.0.0.2"]: Creating...
null_resource.hosts["127.0.0.2"]: Provisioning with 'local-exec'...
null_resource.hosts["127.0.0.2"] (local-exec): Executing: ["/bin/sh" "-c" "echo '127.0.0.2 localhost gitlab.local gitlab.me gitlab.tim' >> hosts.txt"]
null_resource.hosts["127.0.0.2"]: Creation complete after 0s [id=6552627749914505529]
```

Fichier Host :
```
127.0.0.1 localhost gitlab.local
192.169.1.170 prometheus.test
192.169.1.168 gitlab.test
127.0.0.2 localhost gitlab.local
192.169.1.170 prometheus.test
127.0.0.2 localhost gitlab.local gitlab.me
192.169.1.168 gitlab.test
127.0.0.2 localhost gitlab.local gitlab.me gitlab.tim
```

```
terraform destroy
```

## List
Parcourir une liste c'est ``