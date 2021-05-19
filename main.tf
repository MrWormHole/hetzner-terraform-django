terraform {
    required_providers {
        hcloud = {
            source = "hetznercloud/hcloud"
            version = "~> 1.26"
        }
    }
}

provider "hcloud" {
    token = var.hcloud_token
}

variable "hcloud_token" {
    default = "XXX-YOUR-TOKEN-XXX"
    type = string
}

variable "ssh_keys" {
    default = ["XXX-YOUR-SSH-KEY-NAME-XXX"]
    type = list
}

variable "project_name" {
    type = string
}

resource "hcloud_server" "web-server" {
    name = "debian-${var.project_name}"
    image = "debian-10"
    server_type = "cx11"
    location = "nbg1"
    ssh_keys = var.ssh_keys
    user_data = <<-EOF
        #!/bin/bash
        sudo apt update -y
        sudo apt install apache2 libapache2-mod-wsgi-py3  ufw -y
        apt-get install python3-pip python3-dev libpq-dev postgresql postgresql-contrib -y
        sudo ufw default ufw allow outgoing
        sudo ufw default ufw deny incoming
        sudo ufw allow 22
        sudo ufw allow 80
        sudo ufw allow 443
        sudo ufw --force enable
        sudo systemctl start apache2
        EOF
}

output "ipv4_address" {
    value = hcloud_server.web-server.ipv4_address
}
