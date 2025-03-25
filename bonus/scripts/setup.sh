
#!/bin/bash
set -e

# Docs
# Argo CD: https://argo-cd.readthedocs.io/en/stable/getting_started/
# K3D: https://k3d.io/stable

# Installation for Mac Silicon chips
# curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
# curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/arm64/kubectl" 
# or
# brew install k3d
# brew install kubectl  
# brew install argocd

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
RESET=$(tput sgr0)

#kill previous k3s instanced and port forwarding
k3d cluster delete --all || true
pkill -f "kubectl port-forward" || true

k3d cluster create --config ../conf.yml

k3d kubeconfig get dtolmaco > /dev/null

kubectl config use-context k3d-dtolmaco

kubectl create namespace argocd
kubectl create namespace dev

# Create an Argo CD app in argocd namespace
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml > /dev/null

# Wait for ArgoCD pods to be ready
echo -e "${GREEN} Waiting for ArgoCD to be ready... ${RESET}"
while ! kubectl get pods -n argocd | grep "argocd-server" | grep -q "Running"; do
	echo -e "${RED} ArgoCD is not ready yet... ${RESET}"
	sleep 10
	kubectl get pods -n argocd
done
echo -e "${GREEN} ArgoCD is ready! ${RESET}"

kubectl get pods -n argocd

# forward ports to access argocd from localhost:8080
nohup kubectl port-forward svc/argocd-server -n argocd 8080:443 > /dev/null 2>&1 &

PASSWORD=$(argocd admin initial-password -n argocd | head -n 1)
echo -e "${GREEN} Password is ${PASSWORD} ${RESET}"

argocd login localhost:8080 --username admin --password ${PASSWORD} --insecure

# deploy an app from our git
while ! argocd app create dtolmaco-42 --repo https://github.com/julesrb/Inception-of-Things.git --revision dtolmaco/p3 --path p3/confs --dest-server https://kubernetes.default.svc --dest-namespace dev --sync-policy auto; do
	echo "App deployment failed. Retrying..."
	sleep 5
done

# Wait for the app to be ready
echo -e "${GREEN} Waiting for the app to be deployed... ${RESET}"
while ! kubectl get pods -n dev | grep "dtolmaco-42" | grep -q "Running"; do
	echo -e "${RED} App is not ready yet... ${RESET}"
	sleep 10
	kubectl get pods -n dev
done

NAME=$(kubectl get pods -n dev -o custom-columns="NAME:.metadata.name" | grep "dtolmaco-42" | head -n 1)

# forward ports to access deployed app from localhost:8888
nohup kubectl port-forward pod/${NAME} 8888:8888 -n dev > /dev/null 2>&1 &

