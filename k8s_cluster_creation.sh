#!/bin/bash
apt-get update > /dev/null && apt-get install -y apt-transport-https > /dev/null
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
echo "Installing docker and setting up kubernetes cluster, this might take some time..."
sleep 2
apt-get install -y kubelet kubeadm kubectl docker.io > /dev/null
kubeadm init
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
export KUBECONFIG=$HOME/.kube/config >> ~/.bashrc
source ~/.bashrc
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')" > /dev/null
status=`kubectl get nodes | tail -1 | awk '{print $2}'`
echo "Waiting for master node to be ready..."
while [[ $status != "Ready" ]]
do
status=`kubectl get nodes | tail -1 | awk '{print $2}'`
sleep 2
done
echo "Your master node is now ready"
kubectl get nodes
sleep 2
echo "Installing helm on the master node..."
sleep 2
curl -L https://git.io/get_helm.sh | bash
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'      
helm init --service-account tiller --upgrade
echo "Installing nginx ingress controller..."
sleep 2
helm install --name nginx-ingress-controller -f helm_charts/nginx-ingress-controller.yaml stable/nginx-ingress