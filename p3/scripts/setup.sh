#!/bin/bash
set -e

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
RESET=$(tput sgr0)

k3d cluster delete --all

k3d cluster create --config ../confs/conf.yml

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

kubectl get namespaces | grep "argocd"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Namespace created successfully${RESET}"
else
    echo -e "${RED}Failed to create namespace${RESET}"
    exit 1
fi

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

sleep 30

kubectl get pods -n argocd
