module "k8s_master" {
  source              = "./modules/hetzner-k8s-master"
  hcloud_token        = var.hcloud_token
  cluster_name        = "testday-cluster"
  server_type         = "cx22"
  location            = "nbg1"
  ssh_key_name        = "Testday - Server SSH key"
  ssh_public_key_path = "~/.ssh/id_rsa_maklai_hetzner_cloud.pub"
}