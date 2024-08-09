output "k8s_master_ip" {
  description = "The public IP address of the Kubernetes master node"
  value       = hcloud_server.k8s_master.ipv4_address
}