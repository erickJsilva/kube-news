terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}
provider "digitalocean" {
  token = var.do_token
}
resource "digitalocean_kubernetes_cluster" "kube_news" {
  name   = var.k8s_name
  region = var.region
  # Grab the latest version slug from `doctl kubernetes options versions`
  version = "1.23.9-do.0"

  node_pool {
    name       = "default"
    size       = "s-2vcpu-4gb"
    node_count = 2
  }
}

resource "digitalocean_kubernetes_node_pool" "node_premium" {
  cluster_id = digitalocean_kubernetes_cluster.kube_news.id

  name       = "premium"
  size       = "s-2vcpu-4gb"
  node_count = 2
}

variable "do_token" {}
variable "k8s_name" {}
variable "region" {}

output "kube_endpoint" {
    value = digitalocean_kubernetes_cluster.kube_news.endpoint
}

resource "local_file" "kube_config" {
    content  = digitalocean_kubernetes_cluster.kube_news.kube_config.0.raw_config
    filename = "kube_config.yaml"
}

