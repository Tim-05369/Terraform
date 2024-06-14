# Terraform
## Chapitre 1
Terraform c'est quoi ?
C'est un outil dédié aux infrastructure. Il a pour objectif de :
- Construire,
- Modifier
- Et Versionner des infrastructure

On va se baser sur un support, un provider. Gérer facilement son versionning. Bénéficier du système déclaratif au maximum pour pouvoir décrire cette infrastructure. C'est quelque chose qui a explosé depuis le Cloud. Qui a apporté beaucoup de facilité d'appliquer via des API. Terraform se retrouve de plus en plus utilisé.

Il rentre en concurrence contre des outils comme Hansible. Si ce n'est que finalement il se complète plus que d'être vraiment en concurrance. Terraform va être plus stateful que l'autre stateless. On stocke des métadata pour pouvoir savoir quelle est l'infrastructure souhaité tels qu'elle est actuellement. Face à ce qu'elle est dans les jours suivant. être capable de comparer faire un diff et ^de dire voila si j'applique ce que j'ai la dire ce qui va se passer et revenir à la situation initiale.

Terraform est développé par Hashicorp.

C'est une société qui dispose de consult, nomade, vagrant. 

Les providers sont très nombreux. 

Les principaux cloud.

Concepts d'infrastructures.

Grafana.

C'est très variés au niveau infrastructure.

Avant ils étaient centré infra & cloud. Maintenant ça explose de tous les côté. Tous les outils qui disposent d'une api entrée de tous les coté. Tous les outils qui disposent d'une api ou tenté de développer une API pour rentrer dans terraform le font car cela permet de faire du IAC et ainsi intégrer l'infrastructure de la manière la plus large possible.

Donc le terraform, l'objectif c'est de faire des actions sur l'infrastructure. Et ce à partir de fichiers de type HCL Hashicorp. Format HCL. Hashicorp Config Langugage

Le principe c'est 
- On génère un plan d'application qu'on souhaite réaliser
- On le check
- On applique le plan qu'on souhaite réaliser

Réalisation d'infrastructure as Code
- Automatisation d'infrastructure
- Maintenance d'infrastructure
- CI/CD
- Provisionning (application ou des services)

Terraform stocke l'**ETAT**:
- Stockage de l'état (State) de l'infra et sa configuration
Il construit un système de metadata pour construire l'infrastructure tel qu'elle est, si je construit tel infrastructure, ça va entrainer la suppression de tel donnée. ça cause une problématique de :

- diff entre l'état réel et le state // metadata // objectif de perfs sur de large infra

performance.

- State = terraform.tfstate
Le state est stocké dans le tfstate.

- tfstate >> plan >> changements / creation

Il compare le plan, le tfstate, ça provoque tel changement. Est-ce qu'on veut le faire.

## Différentes étapes :
- Refresh
- Plan
- Apply
- Destroy

La commande a utiliser est simplement `Terraform`.

Terraform init > Initialise a Terraform working directory
Terraform plan > Generate and show an execution plan
Terraform apply > Le plan finalement, on considère qu'on va l'exécuter. 
Terraform destroy > Tous va être détruit
Terraform show > Consulter les metadata
Terraform refresh > Remettre à jour localement l'état par rapport aux réelles ressources
Terraform validate > Valider les interfaces fichiers
Terraform import > Faire l'inverse. On veut pouvoir l'importer dans terraform pour pouvoir faire quelque chose.

Fichiers .tf

C'est une brique d'infra qui devient vraiment essentiel. (Instances, containers, switch, firewall, VMs...)
    Cycle de vie : Création / Lecture / Modif / Suppression
- Utilisation par l'API des providers

- Iaas Paas Saas

Kubernetes
Docker
Proxmox
Fortinet

Les principaux cloud provider.

ça permet de s'appuyer sur une stratégie de 
- Iaas (Infrastructure As A Service) - Docker / Kubernetes
- Paas (Plateforme As A Service) - Terraform ou Terraform + Hansible
- Saas (Software As A Service) - Terraform / Ansible

###
- site : https://www.terraform.io/
- utilisable sur de nombreux providers :
    https://www.terraform.io/docs/providers/index.html
- providers de différents types : cloud, software, réseau, database...
- action sur infrastructure > fichiers de configurations (HCL)
- génération d'un plan d'application > application du plan (état final recherché)


