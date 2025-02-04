#!/bin/bash
set -euo pipefail

# Get gateway IP
GATEWAY_IP=$(kubectl get svc -n envoy-gateway-system \
  --selector=gateway.envoyproxy.io/owning-gateway-namespace=default,\
gateway.envoyproxy.io/owning-gateway-name=envoy-ai-gateway-basic \
  -o jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}')

if [ -z "$GATEWAY_IP" ]; then
  echo "Error: Unable to retrieve external IP for the gateway."
  exit 1
fi

export GATEWAY_URL="http://$GATEWAY_IP"
echo "Using Gateway URL: $GATEWAY_URL"

# Test request
curl -s --fail \
  -H "Content-Type: application/json" \
  -H "x-ai-eg-model: phi4" \
  -d '{
        "model": "phi4",
        "messages": [
            {
                "role": "user",
                "content": "What is cloud computing?"
            }
        ],
        "stream": false
    }' \
  "$GATEWAY_URL/v1/chat/completions"
