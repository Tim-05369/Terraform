# Docker network
On va s'intéresser à l'utilisation de cette ressource.

On va créer un network docker avec terraform, comment on l'attribue à un conteneur, qu'est ce qui se passe quand on fait une modification... Et conceptuellement comment aborder ce genre de modification.

Comment on passe un output à un autre en envoyant l'ip de docker.

- BDD avec réseau
- Wordpress
- Réseau
- Persistant de volume qui va bien

Faire tourner ça tout simplement pour faire tourner les bases.

## Resources :
- docker_network
- docker_container

```tf
resource "docker_network" "tim" {
    name = "mynet"
}
```

```sh
docker network ls
```

```sh
terraform apply
```

On voit nos modifications de faites.

```sh
terraform apply -auto-approve
```

```sh
docker network ls
```

Le réseau est bien créé

docker network inspect mynet

On trouve son range_ip.

```sh
docker inspect enginecks
```

Il n'est pas dans le réseau. Pour spécifier un réseau on fait :

```
networks_advanced {
    name = docker_network.xavkinet.name
}
```

```sh
terraform plan
```

```sh
terraform apply -auto-approve
```

```sh
docker inspect enginecks
```

```sh
docker network inspect mynet
```

On voit bien le subnet de défini correctement.

## On veut modifier la configuration du network

Tu vas utiliser un network de type "bridge" et set un range.

```tf
resource "docker_network" "tim" {
    name = "mynet"
    driver = "bridge"
    ipam_config {
        subnet = "177.22.0.0/24"
    }
}
```

Tout est présent dans la documentation du provider docker.

```
terraform plan
```

Il informe qu'il va faloir qu'il change le docker networks.

```
terraform apply
```

Il n'y arrive pas car on a un conteneur qui existe dedans. Il n'est pas informé de cela, ça impacte donc la modification.

La bonne manière de réagir.

La bonne méthode c'est de provoquer la suppression du docker.

Pour la supprimer et la recréer il suffit simplement de changer le nom. Car dans le tfstate (BDD de référence), il ne retrouvera pas le conteneur docker. Ce qui le supprimera.

Il informe donc le tout.

ça provoque en cascade un changement de nom et il informe qu'il va falloir le remplacer.

Si on fait un terraform apply auto-approve.

```
terraform apply
```

Il va faire le travail, et ne pas avoir de problème.

Si je fais un docker ps j'ai toujorus mon conteneur.

Si je fais un network ls,  je n'ai plus le network mynet. 

Si je fais un docker inspect, il est bien affecté au nouveau réseau.

(Mais l'adress ip, je ne vais pas à chaque fois la set...)

Si je fais un `terraform show` terraform informe des informations sur les modules.

Il informe que dans le module docker_container, j'ai toutes ces informations... (ip_address, ip_prefix_length, ...)

On peut donc récupérer directement l'adresse ip.

Dans main.tf on ajoute donc l'output lié au conteneur.

```tf
output "ip_container" {
    value = module.docker_run.container.nginx.ip_address
}
```

Si je fais : 
```sh
terraform apply -auto-approve
```

On nous informe qu'il y a un problème pour trouver le module. Car cette variable n'est pas déclaré.

Pour que cette variable soit disponnible, il faut faire une variable en cascade.

On va donc le faire autrement.

```
output "ip_container" {
    value = module.docker_run.ip_docker
}
```

On crée donc un fichier `outputs.tf` dans lequel on déclare le fameux output.

```
output "ip_docker" {
    value = "docker_container.nginx.ip_address"
}
```

```tf
terraform apply -auto-approve
```

Et la on remarque que l'ip se récupère bien.