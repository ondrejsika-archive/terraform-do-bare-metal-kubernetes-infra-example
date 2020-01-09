variable "do_token" {}
variable "cloudflare_email" {}
variable "cloudflare_token" {}


variable "master_count" {
  default = 1
}

variable "node_count" {
  default = 2
}


provider "digitalocean" {
  token = "${var.do_token}"
}

provider "cloudflare" {
  email = "${var.cloudflare_email}"
  token = "${var.cloudflare_token}"
}


// data "digitalocean_droplet_snapshot" "image" {
//   name  = "kubernetes-bare-metal"
//   region = "fra1"
//   most_recent = true
// }


variable "vm_image" {
  default = "debian-10-x64"
}


data "digitalocean_ssh_key" "ondrejsika" {
  name = "ondrejsika"
}

resource "digitalocean_droplet" "master" {
  count = var.master_count

  image  = var.vm_image
  name   = "m${count.index}.bm"
  region = "fra1"
  size   = "s-2vcpu-2gb"
  ssh_keys = [
    data.digitalocean_ssh_key.ondrejsika.id
  ]
}

resource "cloudflare_record" "master" {
  count = var.master_count

  domain = "sikademo.com"
  name   = "m${count.index}.bm-vm"
  value  = "${digitalocean_droplet.master[count.index].ipv4_address}"
  type   = "A"
  proxied = false
}


resource "digitalocean_droplet" "node" {
  count = var.node_count

  image  = var.vm_image
  name   = "n${count.index}.bm"
  region = "fra1"
  size   = "s-2vcpu-2gb"
  ssh_keys = [
    data.digitalocean_ssh_key.ondrejsika.id
  ]
  tags = ["bm-node"]
}

resource "cloudflare_record" "node" {
  count = var.node_count

  domain = "sikademo.com"
  name   = "n${count.index}.bm-vm"
  value  = "${digitalocean_droplet.node[count.index].ipv4_address}"
  type   = "A"
  proxied = false
}

resource "digitalocean_loadbalancer" "sikademo" {
  name = "sikademo"
  region = "fra1"

  droplet_tag = "bm-node"

  healthcheck {
    port = 30001
    protocol = "tcp"
  }

  forwarding_rule {
    entry_port  = 80
    target_port = 30001
    entry_protocol = "tcp"
    target_protocol = "tcp"
  }

  forwarding_rule {
    entry_port  = 443
    target_port = 30002
    entry_protocol = "tcp"
    target_protocol = "tcp"
  }

  forwarding_rule {
    entry_port  = 8080
    target_port = 30003
    entry_protocol = "tcp"
    target_protocol = "tcp"
  }
}


resource "cloudflare_record" "k8s" {
  domain = "sikademo.com"
  name   = "bm-k8s"
  value  = "${digitalocean_loadbalancer.sikademo.ip}"
  type   = "A"
  proxied = false
}

resource "cloudflare_record" "k8s_wildcard" {
  domain = "sikademo.com"
  name   = "*.${cloudflare_record.k8s.name}"
  value  = "${cloudflare_record.k8s.hostname}"
  type   = "CNAME"
  proxied = false
}
