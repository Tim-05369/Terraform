# Remote Exec & File : commandes via ssh
## Avant-gout

Création d'un DockerFile dans `terraform_server/` avec ssh connexion.


`docker build -t terraform-ssh-container .`

## Remote Exec
Local_exec distant (ssh)

Le tout avec les informations classique de ssh (user, host, private_key)

variable "host" {}
resource "null_resource" "ssh_target" {
    connection {
        type = "ssh"
        user = var.ssh_user
        host = var.ssh_host
        private_key = file("/root/.ssh/id_rsa")
    }
}

### Définir des variables
variable "ssh_host" {}
variable "ssh_user" {}
variable "ssh_key" {}
resource "null_resource" "ssh_target" {
    connection {
        type = "ssh"
        user = var.ssh_user
        host = var.ssh_host
        private_key = file(var.ssh_key)
    }
    provisioner "remote-exec" {
        inline = [
            "sudo apt update -qq >/dev/null",
            "sudo apt install -qq -y nginx >/dev/null
        ]
    }
}

.tfvars

terraform.tfvars
```
ssh_key = "/home/tim/.ssh/id_ed25519"
ssh_user = "root"
ssh_host = "192.168.21.103"
```

```
terraform init
```


```
Terraform used the selected providers to generate
the following execution plan. Resource actions are
indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # null_resource.ssh_target will be created
  + resource "null_resource" "ssh_target" {
      + id = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  - mavariable = "var_file" -> null

────────────────────────────────────────────────────

Note: You didn't use the -out option to save this
plan, so Terraform can't guarantee to take exactly
these actions if you run "terraform apply" now.
```


```
terraform plan
```


```
docker cp /home/tim/.ssh/id_ed25519 <container_id>:/root/.ssh/id_ed25519
docker cp /home/tim/.ssh/id_ed25519.pub <container_id>:/root/.ssh/id_ed25519.pub
``` 

```
docker cp /home/tim/.ssh/id_ed25519.pub f4a07020fe04:/root/.ssh/id_ed25519.pub
```

Ensuite écrire : 
```sh
# /.ssh/config
Host *
    IdentityFile /root/.ssh/id_ed25519
    IdentitiesOnly yes
```

Test connexion

```sh
ssh -i /root/.ssh/id_ed25519 <user>@<hostname>
```

```
terraform apply
```

```
Terraform used the selected providers to generate the
following execution plan. Resource actions are
indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # null_resource.ssh_target is tainted, so must be replaced
-/+ resource "null_resource" "ssh_target" {
      ~ id = "6765777444078915472" -> (known after apply)
    }

Plan: 1 to add, 0 to change, 1 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

null_resource.ssh_target: Destroying... [id=6765777444078915472]
null_resource.ssh_target: Destruction complete after 0s
null_resource.ssh_target: Creating...
null_resource.ssh_target: Provisioning with 'remote-exec'...
null_resource.ssh_target (remote-exec): Connecting to remote host via SSH...
null_resource.ssh_target (remote-exec):   Host: 192.168.21.103
null_resource.ssh_target (remote-exec):   User: root
null_resource.ssh_target (remote-exec):   Password: false
null_resource.ssh_target (remote-exec):   Private key: true
null_resource.ssh_target (remote-exec):   Certificate: false
null_resource.ssh_target (remote-exec):   SSH Agent: true
null_resource.ssh_target (remote-exec):   Checking Host Key: false
null_resource.ssh_target (remote-exec):   Target Platform: unix
null_resource.ssh_target (remote-exec): Connected!

null_resource.ssh_target (remote-exec): WARNING: apt does not have a stable CLI interface. Use with caution in scripts.


null_resource.ssh_target (remote-exec): WARNING: apt does not have a stable CLI interface. Use with caution in scripts.

null_resource.ssh_target (remote-exec): debconf: delaying package configuration, since apt-utils is not installed
null_resource.ssh_target: Creation complete after 4s [id=8664684964139864483]

Apply complete! Resources: 1 added, 0 changed, 1 destroyed.
```

