# Modules - Premiers Pas
Pour rappel, il faut ordonner l'installation des éléments.

1. Docker

Il nous faut une machine qu'on a réinitialisé

Connexion ssh

Répertoire principal - Route Module

Clean .terraform/

```sh
rm -rf .terraform/
rm hosts.txt
rm terraform.tfstate*
mkdir modules # Emplacement ou l'on stocke les modules
mkdir modules/docker_install
sudo apt install tree
```

