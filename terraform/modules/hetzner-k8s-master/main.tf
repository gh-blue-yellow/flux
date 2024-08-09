
# Create a firewall for the Kubernetes master node
resource "hcloud_firewall" "k8s_master_fw" {
  name = "${var.cluster_name}-master-fw"

  # Allow SSH access (port 22) from anywhere
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = ["0.0.0.0/0"]
  }

  # Allow Kubernetes API access (port 6443) from anywhere
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "6443"
    source_ips = ["0.0.0.0/0"]
  }

  # Allow all outbound TCP traffic
  rule {
    direction       = "out"
    protocol        = "tcp"
    port            = "1-65535"
    destination_ips = ["0.0.0.0/0"]
  }

  # Allow all outbound UDP traffic
  rule {
    direction       = "out"
    protocol        = "udp"
    port            = "1-65535"
    destination_ips = ["0.0.0.0/0"]
  }

  # Allow all outbound ICMP traffic
  rule {
    direction       = "out"
    protocol        = "icmp"
    destination_ips = ["0.0.0.0/0"]
  }
}

resource "hcloud_ssh_key" "default" {
  name       = var.ssh_key_name
  public_key = file(var.ssh_public_key_path)
}

# Create the Kubernetes master node
resource "hcloud_server" "k8s_master" {
  name        = "${var.cluster_name}-master"
  image       = "ubuntu-22.04"
  server_type = var.server_type
  location    = var.location
  ssh_keys = [
    hcloud_ssh_key.default.id
  ]

  firewall_ids = [hcloud_firewall.k8s_master_fw.id]

  user_data = <<-EOF
 #cloud-config
package_update: true
package_upgrade: true
packages:
  - apt-transport-https
  - ca-certificates
  - curl
  - gnupg
  - lsb-release
  - software-properties-common

write_files:
  - path: /etc/docker/daemon.json
    content: |
      {
        "exec-opts": ["native.cgroupdriver=systemd"],
        "log-driver": "json-file",
        "log-opts": {
          "max-size": "100m"
        },
        "storage-driver": "overlay2"
      }
    owner: "root:root"
    permissions: "0644"

runcmd:
  # Install Docker
  - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
  - add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  - apt-get update
  - apt-get install -y docker-ce docker-ce-cli containerd.io

  # Create keyrings directory if it doesn't exist
  - mkdir -p /etc/apt/keyrings

  # Add the Kubernetes community-owned repository
  - curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  - echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list
  
  # Update the apt package index
  - apt-get update

  # Install Kubernetes components
  - apt-get install -y kubelet kubeadm kubectl
  - apt-mark hold kubelet kubeadm kubectl

  # Initialize Kubernetes master node
  - kubeadm init --pod-network-cidr=10.244.0.0/16

  # Set up kubeconfig for root user
  - mkdir -p /root/.kube
  - cp -i /etc/kubernetes/admin.conf /root/.kube/config
  - chown root:root /root/.kube/config

  # Install Flannel CNI (Network plugin)
  - kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

  # Enable and start Docker and kubelet services
  - systemctl enable docker
  - systemctl enable kubelet
  - systemctl start docker
  - systemctl start kubelet

  EOF

  labels = {
    cluster = var.cluster_name
    role    = "master"
  }
}