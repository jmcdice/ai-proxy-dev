#!/usr/bin/env bash
set -e

echo "Creating static IP if it doesn't exist..."
if ! gcloud compute addresses describe ollama-ip --global &>/dev/null; then
  gcloud compute addresses create ollama-ip --global
fi

echo "Getting static IP address..."
IP=$(gcloud compute addresses describe ollama-ip --global --format='get(address)')
echo "Static IP is: $IP"
echo "Please ensure DNS record for ollama.pool-side.cc points to this IP"

echo "Deploying Ollama..."
kubectl apply -f k8s/ollama/namespace-ollama.yaml
kubectl apply -f k8s/ollama/backend-config-ollama.yaml
kubectl apply -f k8s/ollama/storage-ollama.yaml
kubectl apply -f k8s/ollama/deployment-ollama.yaml
kubectl apply -f k8s/ollama/service-ollama.yaml
kubectl apply -f k8s/ollama/cert-ollama.yaml
kubectl apply -f k8s/ollama/ingress-ollama.yaml

echo "Waiting for deployment to be ready..."
kubectl -n ollama rollout status deployment/ollama

echo "Ollama deployment complete."
echo "Please configure DNS record for ollama.pool-side.cc to point to: $IP"

