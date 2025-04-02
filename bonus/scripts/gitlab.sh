#!/bin/bash
set -e

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
RESET=$(tput sgr0)

# Reset
helm uninstall gitlab -n gitlab || true
kubectl delete all --all -n gitlab || true
kubectl delete namespace gitlab || true

## Make Volume persitant and crete postgress SQL database (TO DO)
# kubectl apply -f ../confs/PersistantVolumes.yml

# Installing helm 
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh


# Installing GitLab
kubectl create namespace gitlab
helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm install gitlab gitlab/gitlab \
  --set certmanager-issuer.email=me@example.com \
  --namespace gitlab


# Wait for the GitLab pods to be ready
echo -e "${GREEN} Waiting for GitLab to be ready... (can last several minutes)${RESET}"
kubectl get pods -n gitlab
while ! kubectl get pods -n gitlab | grep "gitlab-nginx-ingress-controller" | grep -q "Running"; do
	echo -e "${RED} Pods are Pending... ${RESET}"
	sleep 15
done
kubectl get pods -n gitlab

# Make gitlab available to host
nohup kubectl port-forward svc/gitlab-webservice 8080:8889 -n gitlab > /dev/null 2>&1 &




