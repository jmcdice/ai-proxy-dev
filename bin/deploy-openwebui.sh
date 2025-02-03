#!/usr/bin/env bash
set -e

echo "Creating static IP if it doesn't exist..."
if ! gcloud compute addresses describe openwebui-ip --global &>/dev/null; then
  gcloud compute addresses create openwebui-ip --global
fi

echo "Getting static IP address..."
IP=$(gcloud compute addresses describe openwebui-ip --global --format='get(address)')
echo "Static IP is: $IP"
echo "Please ensure DNS record for openwebui.pool-side.cc points to this IP"

echo "Deploying OpenWebUI..."

# Create tmp directory for manifests if it doesn't exist
MANIFEST_DIR="k8s/openwebui"
mkdir -p "$MANIFEST_DIR"

# Apply manifests in the correct order
echo "Creating namespace..."
kubectl apply -f "$MANIFEST_DIR/namespace-owui.yml"

echo "Creating backend config..."
kubectl apply -f "$MANIFEST_DIR/backend-config-owui.yml"

echo "Creating service..."
kubectl apply -f "$MANIFEST_DIR/service-owui.yml"

echo "Creating SSL certificate..."
kubectl apply -f "$MANIFEST_DIR/cert-owui.yml"

echo "Creating deployment..."
kubectl apply -f "$MANIFEST_DIR/deployment-owui.yml"

echo "Creating ingress..."
kubectl apply -f "$MANIFEST_DIR/ingress-owui.yml"

echo "Waiting for deployment to be ready..."
kubectl -n openwebui rollout status deployment/openwebui

echo "OpenWebUI deployment complete."
echo "Please configure DNS record for openwebui.pool-side.cc to point to: $IP"
echo "Note: SSL certificate provisioning may take 15-30 minutes"

# Optional: Check if Ollama service is available
if kubectl get namespace ollama >/dev/null 2>&1; then
    echo "Verifying Ollama service connectivity..."
    kubectl -n openwebui get pods -l app=openwebui -o name | head -n 1 | xargs -I {} kubectl -n openwebui exec {} -- curl -s http://ollama.ollama.svc.cluster.local/api/version || echo "Warning: Unable to connect to Ollama service"
else
    echo "Warning: Ollama namespace not found. Please ensure Ollama is deployed and running"
fi
