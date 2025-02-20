#!/usr/bin/env bash
set -euo pipefail

# Deploy Envoy Gateway via Helm
deploy_envoy_gateway() {
  echo "Deploying Envoy Gateway..."
  helm upgrade -i eg oci://docker.io/envoyproxy/gateway-helm \
    --version v0.0.0-latest \
    --namespace envoy-gateway-system \
    --create-namespace
}

# Deploy Envoy AI Gateway via Helm
deploy_ai_gateway() {
  echo "Deploying Envoy AI Gateway..."
  helm upgrade -i aieg oci://ghcr.io/envoyproxy/ai-gateway/ai-gateway-helm \
    --version v0.0.0-latest \
    --namespace envoy-ai-gateway-system \
    --create-namespace
}

# Configure Envoy Gateway with AI-specific settings and RBAC
configure_gateway() {
  echo "Applying Envoy Gateway configuration..."
  kubectl apply -f https://raw.githubusercontent.com/envoyproxy/ai-gateway/main/manifests/envoy-gateway-config/config.yaml
  kubectl apply -f https://raw.githubusercontent.com/envoyproxy/ai-gateway/main/manifests/envoy-gateway-config/rbac.yaml
}

# Restart Envoy Gateway to load new configuration
restart_gateway() {
  echo "Restarting Envoy Gateway deployment..."
  kubectl rollout restart -n envoy-gateway-system deployment/envoy-gateway
}

# Wait for Envoy Gateway to be available
wait_for_gateway() {
  echo "Waiting for Envoy Gateway to become available..."
  kubectl wait --timeout=2m -n envoy-gateway-system deployment/envoy-gateway --for=condition=Available
}

# Create or update the OpenAI secret using the OPENAI_API_KEY env var
create_openai_secret() {
  if [ -z "${OPENAI_API_KEY:-}" ]; then
    read -rp "Enter your OpenAI API key: " OPENAI_API_KEY
    if [ -z "$OPENAI_API_KEY" ]; then
      echo "Error: No API key provided."
      exit 1
    fi
  fi
  echo "Creating/updating OpenAI secret..."
  kubectl create secret generic envoy-ai-gateway-basic-openai-apikey \
    --from-literal=apiKey="$OPENAI_API_KEY" \
    --namespace default \
    --dry-run=client -o yaml | kubectl apply -f -
}

# Deploy the basic setup (includes test backend)
deploy_basic_setup() {
  echo "Deploying basic AI Gateway setup..."
  kubectl apply -f https://raw.githubusercontent.com/envoyproxy/ai-gateway/main/examples/basic/basic.yaml
}

# Wait for the basic gateway pod to be ready
wait_for_basic_gateway() {
  echo "Waiting for basic gateway pod to become ready..."
  kubectl wait pods --timeout=2m \
    -l gateway.envoyproxy.io/owning-gateway-name=envoy-ai-gateway-basic \
    -n envoy-gateway-system \
    --for=condition=Ready
}

# Deploy Ollama overlay configuration
deploy_ollama_overlay() {
  echo "Deploying Ollama backend configuration..."
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  K8S_DIR="${SCRIPT_DIR}/../k8s"
  
  # Apply Ollama backend configuration
  kubectl apply -f "${K8S_DIR}/envoy-ai-gateway/config/ollama/backend.yaml"
  kubectl apply -f "${K8S_DIR}/envoy-ai-gateway/config/ollama/secret.yaml"
  
  echo "Applying updated routes..."
  kubectl apply -f "${K8S_DIR}/envoy-ai-gateway/routes/routes.yaml"
  
  echo "Waiting for route configuration to be applied..."
  sleep 5
}

# Verify the deployment
verify_deployment() {
  echo "Verifying deployment..."
  
  # Check gateway components
  echo "Checking gateway components..."
  kubectl get aigatewayroute,aiservicebackend,backend,backendtlspolicy -n default
  
  # Check if Ollama backend is properly configured
  echo "Checking Ollama backend..."
  kubectl get backend envoy-ai-gateway-basic-ollama -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}'
}

main() {
  echo "Starting Envoy AI Gateway deployment..."
  
  # Deploy core components
  deploy_envoy_gateway
  deploy_ai_gateway
  configure_gateway
  restart_gateway
  wait_for_gateway
  echo "Envoy Gateway and AI Gateway deployment complete!"
  
  # Deploy basic setup
  deploy_basic_setup
  wait_for_basic_gateway
  
  # Deploy Ollama overlay
  deploy_ollama_overlay
  
  # Verify deployment
  verify_deployment
  
  echo "Deployment complete! You can now test the gateway with:"
  echo "  ./bin/test-oai.sh     # Test OpenAI backend"
  echo "  ./bin/test-ollama.sh  # Test Ollama backend"
}

main
