# Terraform Hetzner Kubernetes Master Node Module

This Terraform module provisions a Kubernetes master node on Hetzner Cloud.

## Usage

```hcl
module "k8s_master" {
  source       = "./terraform-hetzner-k8s-master"
  hcloud_token = "your_hetzner_api_token"
  cluster_name = "your_cluster_name"
  server_type  = "cx21"
  location     = "nbg1"
  ssh_key_name = "your_ssh_key_name"
  ssh_public_key_path = "your local path for public ssh key"
}
