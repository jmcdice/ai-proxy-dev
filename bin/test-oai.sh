#!/usr/bin/env bash

set -euo pipefail

# Retrieve the external IP for the basic gateway service

echo "Retrieving external IP for the basic gateway..."

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

# Send a test request to the gateway
# echo "Sending test request to gateway..."
curl -s --fail \
  -H "Content-Type: application/json" \
  -H "x-ai-eg-model: gpt-4o-mini" \
  -d '{
        "model": "gpt-4o-mini",
        "messages": [
            {
                "role": "system",
                "content": "Hi."
            }
        ]
    }' \
  "$GATEWAY_URL/v1/chat/completions"
echo

