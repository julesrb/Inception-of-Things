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

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
RESET=$(tput sgr0)

k3d cluster delete --all

k3d cluster create --config ../conf.yml

k3d kubeconfig get dtolmaco > /dev/null

kubectl config use-context k3d-dtolmaco

if [ "$(kubectl config current-context)" = "k3d-dtolmaco" ]; then
    echo -e "${GREEN}Context initialized successfully${RESET}"
else
    echo -e "${RED}Failed to initialize context${RESET}"
    exit 1
fi

kubectl create namespace argocd
kubectl create namespace dev

# Create deployment from Argo CD yaml in argocd namespace
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# give time for pods to load
sleep 10

kubectl get pods -n argocd

# forward ports to access argocd from localhost:8080
kubectl port-forward svc/argocd-server -n argocd 8080:443

# forward ports to access deployed app from localhost:8888
kubectl port-forward pod/dtolmaco-42-ttetwt 8888:8888 -n dev
