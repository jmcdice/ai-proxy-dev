kubectl create secret generic envoy-ai-gateway-basic-openai-apikey \
  --from-literal=apiKey=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 \
  --namespace default \
  --dry-run=client -o yaml | kubectl apply -f -

