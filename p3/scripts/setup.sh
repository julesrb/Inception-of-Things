#!/bin/bash
set -e

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
RESET=$(tput sgr0)

k3d cluster delete --all

k3d cluster create dtolmaco

kubectl create namespace argocd
kubectl create namespace dev

# Create an Argo CD app in argocd namespace
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml > /dev/null

# give time for argocd to load
echo -e "${GREEN} Sleeping for 40 seconds ${RESET}"
sleep 40

kubectl get pods -n argocd

function start_argocd_port_forwarding {
    local retries=5
    local count=0
    
    while true; do
        if ! lsof -i :8080 > /dev/null; then
            echo "Port-forwarding not running for ArgoCD on localhost:8080. Attempting to start..."
            nohup kubectl port-forward svc/argocd-server -n argocd 8080:443 > /dev/null 2>&1 &
            count=$((count + 1))
            
            if [ $count -lt $retries ]; then
                echo "Retry $count of $retries..."
            else
                echo "Failed to start port-forwarding after $retries attempts. Continuing..."
            fi
        fi
        sleep 10
    done
}

start_argocd_port_forwarding &

PASSWORD=$(argocd admin initial-password -n argocd | head -n 1)
echo -e "${GREEN} Password is ${PASSWORD} ${RESET}"

argocd login localhost:8080 --username admin --password ${PASSWORD} --insecure

# deploy an app from our git
while ! argocd app create dtolmaco-42 --repo https://github.com/julesrb/jubernar.git --revision main --path conf/ --dest-server https://kubernetes.default.svc --dest-namespace dev --sync-policy auto; do
	echo "App deployment failed. Retrying..."
	sleep 5
done

sleep 10

NAME=$(kubectl get pods -n dev -o custom-columns="NAME:.metadata.name" | grep "dtolmaco-42" | head -n 1)

# Function to start port-forwarding
function start_port_forwarding {
    nohup kubectl port-forward pod/${NAME} 8888:8888 -n dev > /dev/null 2>&1 &
    echo "Port-forwarding started on pod ${NAME} to localhost:8888"
}

# Start initial port forwarding
start_port_forwarding

# Monitor the pod and restart port-forwarding if the pod changes
while true; do
    NEW_NAME=$(kubectl get pods -n dev -o custom-columns="NAME:.metadata.name" | grep "dtolmaco-42" | head -n 1)
    
    if [ "$NEW_NAME" != "$NAME" ]; then
        echo "Pod has changed. Restarting port-forwarding..."
        pkill -f "kubectl port-forward"  # Kill the previous port-forwarding process
        NAME=$NEW_NAME
        start_port_forwarding
    fi
    
    sleep 10  # Check every 10 seconds
done
