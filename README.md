# Haytham-DevOps-GitOps-Task
# 01 script


# 02 k8s task
## 02.1 created on master and one worker on my mac using multipass

```bash
# 01 on the mac install multipass
└─➜ brew ibrew install --cask multipass

# 02 use this command to check VMs using multipass
└─➜ multipass list

# 03 create master VM 
multipmultipass launch 22.04 --name master --cpus 2 --memory 4G --disk 20G

# 04 create  worker VM
multipmultipass launch 22.04 --name master --cpus 2 --memory 4G --disk 20G

# 05 check the VMs
└─➜ multipass list
Name                    State             IPv4             Image               Zone
master                  Running           192.168.252.2    Ubuntu 22.04 LTS    zone1
worker1                 Running           192.168.252.3    Ubuntu 22.04 LTS    zone1

# 06 ssh to master
└─➜ multipass shell master
ubuntu@master:~$ sudo -i
root@master:~#

# 07 update
root@master:~# apt update

# 08 install containerd
root@master:~# sudo apt install -y containerd

# 09 create the dir for containerd and the configuration
root@master:~# sudo mkdir -p /etc/containerd
root@master:~# containerd config default
root@master:~# containerd config default | sudo tee /etc/containerd/config.toml

# 10 enabe the cgroup
root@master:~# sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
root@master:~# sudo systemctl restart containerd
root@master:~# sudo systemctl enable containerd

# 11 Configure required kernel modules
root@master:~# sudo modprobe overlay
sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

# 12 Configure iptables 
root@master:~# cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
EOF
sudo sysctl --system

# 13 install k8s pkgs for 1.35
root@master:~# sudo apt install -y apt-transport-https ca-certificates curl

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key | \
sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /" | \
sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# 14 Initialize the cluster
root@master:~# sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# 15 Configure kubectl for the ubuntu user
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 16 copy the join command till finish worker
kubeadm join 192.168.252.2:6443 --token clyjy8.0wgihn12ohc8oxax \
        --discovery-token-ca-cert-hash sha256:38a907ac562ad01023972160b90ac873533bc6f0ae7facea4e3a9cf1cfd21780

17 configure network plugins,  in this demo will use flannel
root@master:~# kubectl apply -f \
https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
namespace/kube-flannel created
serviceaccount/flannel created
clusterrole.rbac.authorization.k8s.io/flannel created
clusterrolebinding.rbac.authorization.k8s.io/flannel created
configmap/kube-flannel-cfg created
daemonset.apps/kube-flannel-ds created

# 18 go to worker
└─➜ multipass list
master                  Running           192.168.252.2    Ubuntu 22.04 LTS    zone1
worker1                 Running           192.168.252.3    Ubuntu 22.04 LTS    zone1


# 19 multipass shell worker1
ubuntu@worker1:~$ sudo -i

# 20 install containerd and configure it like master
root@worker1:~# # Install containerd
sudo apt update
sudo apt install -y containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' \
/etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

# 21 Configure required kernel modules
sudo modprobe overlay
sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
EOF
sudo sysctl --system

# 22 Install Kubernetes packages
sudo apt install -y apt-transport-https ca-certificates curl
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key | \
sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /" | \
sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubelet kubeadm
sudo apt-mark hold kubelet kubeadm

# 23 put the join command that copied from master
root@worker1:~# kubeadm join 192.168.252.2:6443 --token clyjy8.0wgihn12ohc8oxax \
> --discovery-token-ca-cert-hash sha256:38a907ac562ad01023972160b90ac873533bc6f0ae7facea4e3a9cf1cfd21780

# 24 go to master node and check the node status, it is ready
root@master:~# kubectl get nodes
NAME      STATUS   ROLES           AGE   VERSION
master    Ready    control-plane   55m   v1.35.10
worker1   Ready    <none>          47m   v1.35.10
root@master:~#


```
