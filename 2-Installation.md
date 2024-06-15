# Installation de Terraform
## Objectif
On va faire un premier `Hello World`.

## Installer Terraform sur Linux
Pour installer terraform sur linux :
```sh
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```


## Créer un Projet
On crée un projet dans le dossier `/projet`

## Initialisation de terraform
```sh
terraform init`
```

Une fois ça le projet est vide. Logique. 
Normalement quand on commence un projet terraform on a des fichiers .ts. La on a rien du tout.

## Création d'un fichier main.tf
On utilise le module output de terraform
```
output "mavariable" {
    value = "Hello World !!"
}
```
## On affiche le plan
```sh
terraform plan
```

### Résultat de la requête :
```txt
Changes to Outputs:
  + mavariable = "Hello World !!"

You can apply this plan to save these new output values to the
Terraform state, without changing any real infrastructure.

───────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so
Terraform can't guarantee to take exactly these actions if you run
"terraform apply" now
```

## On applique les modifications terraform
Si on fait un `terraform apply` :
```txt
Changes to Outputs:
  + mavariable = "Hello World !!"

You can apply this plan to save these new output values to the
Terraform state, without changing any real infrastructure.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes


Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

mavariable = "Hello World !!"
```

Il m'informe qu'il y a un output (ma variable)

## Liste des fichiers
```sh
ls -la
```

```txt
total 16
drwxrwxr-x 2 tim tim 4096 juin  15 17:31 .
drwxrwxr-x 4 tim tim 4096 juin  15 17:23 ..
-rw-rw-r-- 1 tim tim   52 juin  15 17:27 main.tf
-rw-rw-r-- 1 tim tim  265 juin  15 17:31 terraform.tfstate
```

On observe un fichier `terraform.tfstate` qui comprends l'état quand notre terraform a été appliqué. Donc l'état de nos ressource. C'est une base de données de l'état global de l'infrastructure / des ressources. Permettant donc le versionning ?

