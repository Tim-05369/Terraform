# Préférences des variables
## Cas classique
type de variables :
- string
- number
- bool
- liste
- map

Déclaration
```
    variable "mybool" {
        type = "bool"
        default = true
    }
```

## Que se passe-t-il si on crée une variable vide ?
```
variable "str" {}
output *"mavariable" {
    value = var.str
}
```

Voici le retour :
```
var.str
  Enter a value: 
```

On nous demande de la rentrer.

Je rentre `Tim` en valeur.

```txt
var.str
  Enter a value: tim

null_resource.hosts[0]: Refreshing state... [id=2042905731532277767]
null_resource.hosts[1]: Refreshing state... [id=7644773937671134369]

Terraform used the selected providers to generate the
following execution plan. Resource actions are
indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # null_resource.hosts[0] will be destroyed
  # (because null_resource.hosts is not in configuration)
  - resource "null_resource" "hosts" {
      - id = "2042905731532277767" -> null
    }

  # null_resource.hosts[1] will be destroyed
  # (because null_resource.hosts is not in configuration)
  - resource "null_resource" "hosts" {
      - id = "7644773937671134369" -> null
    }

Plan: 0 to add, 0 to change, 2 to destroy.

Changes to Outputs:
  + mavariable = "tim"

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

null_resource.hosts[1]: Destroying... [id=7644773937671134369]
null_resource.hosts[0]: Destroying... [id=2042905731532277767]
null_resource.hosts[1]: Destruction complete after 0s
null_resource.hosts[0]: Destruction complete after 0s

Apply complete! Resources: 0 added, 0 changed, 2 destroyed.

Outputs:

mavariable = "tim"
```

## Autre méthode de définir la variable
```
variable "str" {}
output *"mavariable" {
    value = "${var.str}
}
```

Si on fait un apply, il demande la même chose et ça reste fonctionnel.

```
var.str
  Enter a value: Tim_2


Changes to Outputs:
  ~ mavariable = "tim" -> "Tim_2"

You can apply this plan to save these new output values
to the Terraform state, without changing any real
infrastructure.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes


Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

mavariable = "Tim_2"
```

## Niveaux
On peut définir des variables à plusieurs niveaux : environnement > fichier spécifique

Ordre des variables :
1. Environnement
2. Fichier : terraform.tfvars
3. Fichier json : terraform.tfvars.json
4. Fichier *.auto.tfvars ou *.auto.tfvars.json
5. CLI : -var ou - var-file

environnement :

```
export TF_VAR_str="environnement"
terraform apply
```

Résultat :

```
Changes to Outputs:
  ~ mavariable = "Tim_2" -> "environnement"

You can apply this plan to save these new output values
to the Terraform state, without changing any real
infrastructure.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes


Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

mavariable = "environnement"
```

Pour unset une variable :
```
unset TF_VAR_mavariable
```

Nous n'appliquons pas cette commande pour le moment.

### Terraform.tfvars

Désormais utilisons le fichier terraform.tfvars.

```
Changes to Outputs:
  ~ mavariable = "environnement" -> "terraform"

You can apply this plan to save these new output values
to the Terraform state, without changing any real
infrastructure.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes


Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

mavariable = "terraform"
```

On observe bien que le fichier terraform.tfvars emporte la valeur de la variable face à un export classique.

### *.auto.tfvars
production.auto.tfvars
```
str="auto"
```

```
terraform apply
```

```
Changes to Outputs:
  ~ mavariable = "terraform" -> "auto"

You can apply this plan to save these new output values
to the Terraform state, without changing any real
infrastructure.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes


Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

mavariable = "auto"
```

Le niveau le plus fort production.auto.tfvars
l'emporte

### -var "data"
```
terraform apply -var 'str="data"'
```

```

Changes to Outputs:
  ~ mavariable = "auto" -> "\"data\""

You can apply this plan to save these new output values
to the Terraform state, without changing any real
infrastructure.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes


Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

mavariable = "\"data\""
```

### Similaire à ligne de commande
var_file