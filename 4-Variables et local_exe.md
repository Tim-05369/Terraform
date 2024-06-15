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