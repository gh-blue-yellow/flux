variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
  default     = "maklai-k8s-cluster"
}

variable "server_type" {
  description = "The type of server to use for the Kubernetes master node"
  type        = string
  default     = "cx22"
}

variable "location" {
  description = "The location for the Hetzner Cloud server"
  type        = string
  default     = "nbg1"
}

variable "ssh_key_name" {
  description = "Name of the SSH key"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key"
  type        = string
}

