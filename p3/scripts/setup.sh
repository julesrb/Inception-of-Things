#!/bin/bash
set -e

# Installation for Mac Silicon chips

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
RESET=$(tput sgr0)

k3d cluster delete --all

if [ $? -eq 127 ]; then
    echo -e "${GREEN} Installing k3d ${RESET}"
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
    k3d cluster delete --all
fi

k3d cluster create --config ../confs/conf.yml

k3d kubeconfig get dtolmaco > /dev/null

kubectl config use-context k3d-dtolmaco

if [ $? -eq 127 ]; then
    echo -e "${GREEN} Installing kubectl${RESET}"
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/arm64/kubectl"   
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    kubectl config use-context k3d-dtolmaco
fi

if [ "$(kubectl config current-context)" = "k3d-dtolmaco" ]; then
    echo -e "${GREEN}Context initialized successfully${RESET}"
else
    echo -e "${RED}Failed to initialize context${RESET}"
    exit 1
fi

kubectl create namespace argocd
kubectl create namespace dev

kubectl get namespaces | grep "argocd"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Namespace created successfully${RESET}"
else
    echo -e "${RED}Failed to create namespace${RESET}"
    exit 1
fi

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

sleep 5

kubectl get pods -n argocd
