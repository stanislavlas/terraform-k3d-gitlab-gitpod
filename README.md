# [GitLab](https://gitlab.com) and [Gitpod](https://gitpod.io) installation on [k3d](https://k3d.io/) deployed by [Terraform](https://www.terraform.io/)

This repository is an example how to install [GitLab](https://gitlab.com) and [Gitpod](https://gitpod.io) on [k3d](https://k3d.io/) using [Terraform](https://www.terraform.io/)

## Prerequisites

You need to have the following tools installed:
- [Docker](https://www.docker.com/)
- [Terraform](https://www.terraform.io/)

You need a SSL certificate for these domains in `/certs` folder:
- `<domain>`
- `*.<domain>`
- `*.gitlab.<domain>`
- `*.gitpod.<domain>`
- `*.ws.gitpod.<domain>`

You could get a certificate from [Let’s Encrypt](https://letsencrypt.org/):
```shell
$ docker run -it --rm --name certbot \
    -v $WORKDIR/etc:/etc/letsencrypt \
    -v $WORKDIR/var:/var/lib/letsencrypt \
        certbot/certbot certonly \
            -v \
            --email <email> \
            --manual \
            --preferred-challenges=dns \
            --agree-tos \
            -d <domain> \
            -d *.<domain> \
            -d *.gitlab.<domain> \
            -d *.gitpod.<domain> \
            -d *.ws.gitpod.<domain>
```

## Installation
Deployment and installation is done by [Terraform](https://www.terraform.io/). It creates two [k3d](https://k3d.io/) clusters, one for [GitLab](https://gitlab.com) (on port `1443`), and another for [Gitpod](https://gitpod.io) (on port `2443`). On top of that, it creates [nginx](https://www.nginx.com/) reverse proxy that listens on port `443` of the host machine and route communication to appropriate cluster. The configuration is stored in the `terraform.tfvars`. Make sure the config file contains correct values!

```
terraform init
terraform apply -auto-approve
```

Username for [GitLab](https://gitlab.com) is `root` and password is stored in `gitlab/initRootPasswd.txt`. The password is valid for 24 hours. It is recommanded to change it as soon as possible
