# Concepts et définition
Dans ce chapitre, nous parlerons des principales notions et définitions à connaitre.

Il en existe peu ce qui permet d'être facilement abordable.

Terraform est développé en Go. Les éléments dont la manière sont défini reposent sur ce language.

On a la possibilité d'observer la liste des providers afin de créer des ressource/éléments qui existent qui vont être nécessaire pour notre infrastructure. La somme est considérable et très varié.

On observe BDD, Cloud, Kubernetes, Docker...

On va en tester pas mal plus tard.

## Définition du Provider
Un Provider a comme objectif de fournir une API a terraform pour se connecter et interragir dessus et ainsi créer des éléments appelé ressource pour créer de l'infrastructure. C'était la manière la plus facile de le comprendre.

A la base c'était simplement orienté pour du cloud.
Puis ça s'est étendu pour des fournisseurs (VMWare)
Il y a beaucoup d'autres outils pour faire des choses.

On a Docker qui a une API. Kubernetes aussi. Dès lors qu'il y a une API, Terraform va aider à interragir avec cet ensemble d'API. Tout ça en utilisant Go.

Comme dit précédemment, il y a beaucoup de provider.

La manière dont se décrit un provider est :
```tf
provider "kubernetes" {
    version = "-> 1.10
}
```

On informe dedans la version qu'on souhaite utiliser pour interragir avec lui. La version est importante car comme on fonctionne par API, les versions évoluent. Le versionning est important pour garder un système fonctionnel et mieux gérer les futurs changements de version.

## Resource
Le provider c'est le point de contact et il va permettre de faire des choses. 

Ces choses ça va être du CRUD pour créer, lire, modifier et supprimer des ressources. 

Les ressources ce sont des briques mise à disposition par les API de Providers. 

Via cet API Terraform va dire :
- Crée moi un Dashboard grafana
- Crée moi une instance AWS
- Crée moi une règle Fortinet
- [...]

Provider -> API d'entrée principale
Resource -> Elements qu'on peut déployer ou utiliser.

On va aussi voir les DataSources éléments uniquement consultable par les ressources.

Un objet d'une ressource est unique (1 nom) dans un même module.

Une resource s'écrit comme ceci :

```tf
resource "ressource_type" "ressource_nom" {
    arg = "valeur"
}
```

1. Mot clé ressource
2. Type de ressource
3. Nom de la ressource
4. {
   1. argument 1
   2. argument 2
   3. argument 3
   4. [...]
5. }

Suivant les éléments il y a des choses plus ou moins détaillé avec la possibilité de variabiliser des éléments à l'intérieur. Permettant de rendre le système un peu plus lisible. De faire interragir les éléments les uns avec les autres. Par exemple si on crée un security group par exemple sur AWS et qu'on en a besoin pour une instance on va pouvoir l'appeler depuis cette variable puisqu'il vient d'être créé.

exemple concret pour créer une instance AWS lié à notre projet:
```tf
resource "aws_instance" "web" {
    ami = "some-ami-id"
    instance_type = "t2-micro"
}
```

ami -> Image permettant de créer cette instance
instance_type -> type d'instance

## DataSource
On a parlé de DataSource rapidement précédemment.

C'est la même chose qu'une ressource. Sauf que la ressource c'est une CRUD uniquement.

Parfois les providers ont besoin de retourner des choses en lecture seul. Par exemple si on prend une image venant d'AWS, une partie des images ne peuvent pas être modifié. 

L'objectif des datasources est de donner de l'information, une source de donnée. Un peu comme une base de données. 

Pour le code, le principe est un peu le même :

```txt
data "aws_ami" "ubuntu" {
    most_recent = true
    filter {
        name = "name"
        values = ["myami",*]
    }
}
```

1. Source de donnée
2. type de DataSource
3. Nom
4. {
   1.  paramètres
   2.  Filtres custom
       1.  White card
       2.  [...]
5. }

## Meta-arguments
Il n'y en a pas beaucoup.

### Count
Le count permet de faire des itérations sur la ressource sur laquelle on travail. 

```
resource "ressource_type" "ressource_nom" {
    count = nb
    arg = "valeur"
}
```

On observe dans l'exemple ci dessus qu'on a une ressource, un mot clé, le nom de la resource et derrière on fait un `count`. Si on a un count de 1 on fait qu'une itération de cela. Si on a un count de 2 on va faire 2 fois cet itération la. Et ainsi de suite.

On a le principe d'itération plus poussé / complexe du `foreach` qu'on voit plus tard.

## Variables
On a la possibilité de créer des variables.

Pour créer une variable :

```
variable "instances" {
    type = "map"
    default = {
        clef1 = "123"
        clef2 = "456"
        clef3 = "789"
    }
}
``` 

1. Type
2. Par défault, on la set avec la valeur...
   1. {
      1. Valeur 1
      2. Valeur 2
      3. Valeur 3
   2. }


## Foreach
Admettons qu'on a besoin de créer des instances en utilisant cette map. On utilise donc des mots clés ressource, ressource type on affecte un nom serveur. Et on dit qu'on utilise une boucle dans les paramètres dans les éléments qui sont utilisé pour utiliser cette ressource. On dit qu'on utilise foreach.

Exemple de code :
```
variable "instances" {
    type = "map"
    default = {
        clef1 = "123"
        clef2 = "456"
        clef3 = "789"
    }
}
resource "aws_instance" "server" {
    for_each = var.instances
    ami = each.value
    instance_type = "t2.micro"
    tags = {
        Name = each.key
    }
}
```

1. Variable
2. Resource
   1. Boucle chaque instance
   2. Récupère la valeur de l'instance (each étant chaque élément 1 par 1)
   3. On défini une instance type (t2.micro)
   4. On défini des tags
      1. Je récupère la clé en tant que nom

L'association clé-valeur est utilisé au niveau de la ressource.

## State
Notion Super importante, le State.

Le State c'est le stockage de l'état des ressources. 
Plus simplement la base de données par défaut qui est local. De l'endroit de la machine sur laquelle on fait tourner terraform. Fichier .tfstate informant a terraform pour dire dans quelle état est l'infrastructure en face. Et cela permet de faire un diff et savoir quelle tâche il doit réaliser pour la remettre dans le nouvel état décrit.

Le tfstate, l'inconvénient c'est de travailler à plusieurs sur un tfstate. Il y a des nécessité de synchroniser très souvent les tfstate etc.


La solution à cela Remote State :
- consul
- s3
- postgres
- ...

L'intérêt c'est de déporter pour centraliser le state et faire en sorte que quand on est plusieurs à travailler dessus de pouvoir appelé un seul et unique remote, un seul et unique state qui va être stocké de manière divers et variés.

**ATTENTION AUX STATES** ou il peut y avoir des données sensibles. Ne pas envoyer de données sensible vers consul etc... 