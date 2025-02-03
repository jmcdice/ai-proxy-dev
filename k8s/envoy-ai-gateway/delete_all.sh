# Delete current resources
kubectl delete namespace envoy-gateway-system envoy-ai-gateway-system
kubectl delete -f basic.yaml || true
kubectl delete aigatewayroute,aiservicebackend,backend,backendtlspolicy,backendsecuritypolicy --all
kubectl delete secret envoy-ai-gateway-basic-openai-apikey envoy-ai-gateway-basic-ollama-apikey || true
