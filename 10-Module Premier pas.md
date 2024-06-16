# Modules - Premiers Pas
Add user to sudoers

```
echo '${var.ssh_user} ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/${var.ssh_user}
```

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

terraform.tfvars
```go
ssh_key = "/home/tim/.ssh/id_ed25519"
ssh_user = "tim"
ssh_host = "192.168.1.26"
```

tree
```
├── projet
│   ├── main.tf
│   ├── modules
│   │   └── docker_install
│   ├── nginx.conf
│   └── terraform.tfvars
```

## Copier main.tf dans modules/docker_install/
```
cp main.tf modules/docker_install/main.tf
```

modules/docker_install/variables.tf
```
variable "ssh_host" = {}
variable "ssh_user" = {}
variable "ssh_key" = {}
```

## Modifier main.tf pour appeler le module

```
variable "ssh_host" {}
variable "ssh_user" {}
variable "ssh_key" {}

module "docker_install" {
    source = "./modules/docker_install/"
    ssh_host = var.ssh_host
    ssh_user = var.ssh_host
    ssh_key = var.ssh_host
}
```

Cheminement

main.tf (récupère les variables) --> modules/docker_install/ --> variables.tf --> modules/docker_install/main.tf

Chemin
```
.
├── main.tf
├── modules
│   └── docker_install
│       ├── main.tf
│       └── variables.tf
├── nginx.conf
└── terraform.tfvars
```

## Finition
On a fini notre personnalisation

comme on a clean on fait un `terraform get`.

```
- docker_install in modules/docker_install
```

```
terraform init
```

```
Initializing the backend...
Initializing modules...

Initializing provider plugins...
- Reusing previous version of hashicorp/null from the dependency lock file
- Installing hashicorp/null v3.2.2...
- Installed hashicorp/null v3.2.2 (signed by HashiCorp)

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

```sh
terraform plan
```

```
Terraform used the selected providers to generate the
following execution plan. Resource actions are
indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.docker_install.null_resource.ssh_target will be created
  + resource "null_resource" "ssh_target" {
      + id = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

───────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan,
so Terraform can't guarantee to take exactly these
actions if you run "terraform apply" now.
```

```sh
terraform apply -auto-approve
```

```
module.docker_install.null_resource.ssh_target: Refreshing state... [id=4534968889773233229]

Terraform used the selected providers to generate the
following execution plan. Resource actions are
indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # module.docker_install.null_resource.ssh_target is tainted, so must be replaced
-/+ resource "null_resource" "ssh_target" {
      ~ id = "4534968889773233229" -> (known after apply)
    }

Plan: 1 to add, 0 to change, 1 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

module.docker_install.null_resource.ssh_target: Destroying... [id=4534968889773233229]
module.docker_install.null_resource.ssh_target: Destruction complete after 0s
module.docker_install.null_resource.ssh_target: Creating...
module.docker_install.null_resource.ssh_target: Provisioning with 'remote-exec'...
module.docker_install.null_resource.ssh_target (remote-exec): Connecting to remote host via SSH...
module.docker_install.null_resource.ssh_target (remote-exec):   Host: 192.168.1.26
module.docker_install.null_resource.ssh_target (remote-exec):   User: tim
module.docker_install.null_resource.ssh_target (remote-exec):   Password: false
module.docker_install.null_resource.ssh_target (remote-exec):   Private key: true
module.docker_install.null_resource.ssh_target (remote-exec):   Certificate: false
module.docker_install.null_resource.ssh_target (remote-exec):   SSH Agent: true
module.docker_install.null_resource.ssh_target (remote-exec):   Checking Host Key: false
module.docker_install.null_resource.ssh_target (remote-exec):   Target Platform: unix
module.docker_install.null_resource.ssh_target (remote-exec): Connected!

module.docker_install.null_resource.ssh_target (remote-exec): WARNING: apt does not have a stable CLI interface. Use with caution in scripts.

module.docker_install.null_resource.ssh_target (remote-exec): Warning: the "docker" command appears to already exist on this system.

module.docker_install.null_resource.ssh_target (remote-exec): If you already have Docker installed, this script can cause trouble, which is
module.docker_install.null_resource.ssh_target (remote-exec): why we're displaying this warning and provide the opportunity to cancel the
module.docker_install.null_resource.ssh_target (remote-exec): installation.

module.docker_install.null_resource.ssh_target (remote-exec): If you installed the current Docker package using this script and are using it
module.docker_install.null_resource.ssh_target (remote-exec): again to update Docker, you can safely ignore this message.

module.docker_install.null_resource.ssh_target (remote-exec): You may press Ctrl+C now to abort this script.
module.docker_install.null_resource.ssh_target (remote-exec): + sleep 20
module.docker_install.null_resource.ssh_target: Still creating... [10s elapsed]
module.docker_install.null_resource.ssh_target: Still creating... [20s elapsed]
module.docker_install.null_resource.ssh_target (remote-exec): + sh -c apt-get update -qq >/dev/null
module.docker_install.null_resource.ssh_target (remote-exec): + sh -c DEBIAN_FRONTEND=noninteractive apt-get install -y -qq apt-transport-https ca-certificates curl >/dev/null
module.docker_install.null_resource.ssh_target (remote-exec): + sh -c install -m 0755 -d /etc/apt/keyrings
module.docker_install.null_resource.ssh_target (remote-exec): + sh -c curl -fsSL "https://download.docker.com/linux/ubuntu/gpg" -o /etc/apt/keyrings/docker.asc
module.docker_install.null_resource.ssh_target (remote-exec): + sh -c chmod a+r /etc/apt/keyrings/docker.asc
module.docker_install.null_resource.ssh_target (remote-exec): + sh -c echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu noble stable" > /etc/apt/sources.list.d/docker.list
module.docker_install.null_resource.ssh_target (remote-exec): + sh -c apt-get update -qq >/dev/null
module.docker_install.null_resource.ssh_target (remote-exec): + sh -c DEBIAN_FRONTEND=noninteractive apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-ce-rootless-extras docker-buildx-plugin >/dev/null
module.docker_install.null_resource.ssh_target (remote-exec): + sh -c docker version
module.docker_install.null_resource.ssh_target (remote-exec): Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?
module.docker_install.null_resource.ssh_target: Provisioning with 'file'...
module.docker_install.null_resource.ssh_target: Provisioning with 'remote-exec'...
module.docker_install.null_resource.ssh_target (remote-exec): Connecting to remote host via SSH...
module.docker_install.null_resource.ssh_target (remote-exec):   Host: 192.168.1.26
module.docker_install.null_resource.ssh_target (remote-exec):   User: tim
module.docker_install.null_resource.ssh_target (remote-exec):   Password: false
module.docker_install.null_resource.ssh_target (remote-exec):   Private key: true
module.docker_install.null_resource.ssh_target (remote-exec):   Certificate: false
module.docker_install.null_resource.ssh_target (remote-exec):   SSH Agent: true
module.docker_install.null_resource.ssh_target (remote-exec):   Checking Host Key: false
module.docker_install.null_resource.ssh_target (remote-exec):   Target Platform: unix
module.docker_install.null_resource.ssh_target (remote-exec): Connected!
module.docker_install.null_resource.ssh_target: Still creating... [30s elapsed]
module.docker_install.null_resource.ssh_target: Still creating... [40s elapsed]
module.docker_install.null_resource.ssh_target: Creation complete after 47s [id=2462056202068015941]

Apply complete! Resources: 1 added, 0 changed, 1 destroyed.
```
