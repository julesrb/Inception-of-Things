#!/bin/bash
set -e

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
RESET=$(tput sgr0)


# Add kubernetes-dashboard repository
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
# Deploy a Helm Release named "kubernetes-dashboard" using the kubernetes-dashboard chart
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard

echo -e "${GREEN} Waiting for the app to be deployed... ${RESET}"
while ! kubectl get pods -n kubernetes-dashboard | grep "kubernetes-dashboard-kong" | grep -q "Running"; do
	echo -e "${RED} Kubernetes dashboard is not ready yet... ${RESET}"
	sleep 10
	kubectl get pods -n kubernetes-dashboard
done

# Expose dashbaord to the host
nohup kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443 > /dev/null 2>&1 &

# generate dahsboard Token
kubectl create serviceaccount dashboard-admin -n kubernetes-dashboard
kubectl create clusterrolebinding dashboard-admin \
  --clusterrole=cluster-admin \
  --serviceaccount=kubernetes-dashboard:dashboard-admin
TOKEN=$(kubectl create token dashboard-admin -n kubernetes-dashboard)
echo "Dashboard available at https://127.0.0.1:8443 with token $(TOKEN)"


# Reset
helm uninstall gitlab -n gitlab || yes
kubectl delete all --all -n gitlab
kubectl delete namespace gitlab


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




