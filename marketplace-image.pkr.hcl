packer {
  required_plugins {
    digitalocean = {
      version = ">= 1.2.0"
      source  = "github.com/digitalocean/digitalocean"
    }
  }
}

variable "digitalocean_token" {
  default = "${env("DIGITALOCEAN_TOKEN")}"
  type     = string
}

variable "image_name" {
  default = ""
  type    = string
}

locals {
  timestamp  = regex_replace(timestamp(), "[- TZ:]", "")
  image_name = var.image_name == "" ? "mastodon-digitalocean-${local.timestamp}" : var.image_name
}

source "digitalocean" "debian" {
  api_token     = "${var.digitalocean_token}"
  image         = "debian-12-x64"
  region        = "nyc3"
  size          = "s-1vcpu-2gb"
  snapshot_name = "${var.image_name}"
  ssh_username  = "root"
}

build {
  sources = ["source.digitalocean.debian"]

  provisioner "shell" {
    scripts = ["scripts/01-prepare.sh"]
  }

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; su -c '{{ .Vars }} {{ .Path }}' - mastodon"
    scripts         = ["scripts/02-install.sh"]
  }

  provisioner "file" {
    destination = "/etc/"
    source      = "files/etc/"
  }

  provisioner "file" {
    destination = "/var/"
    source      = "files/var/"
  }

  provisioner "file" {
    destination = "/opt/"
    source      = "files/opt/"
  }

  provisioner "file" {
    destination = "/home/"
    source      = "files/home/"
  }

  provisioner "shell" {
    scripts = ["scripts/03-finalize.sh"]
  }

  provisioner "shell" {
    scripts = [
      "scripts/90-cleanup.sh",
      "scripts/99-img_check.sh"
    ]
  }
}
