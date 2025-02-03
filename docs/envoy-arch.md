
```console
  GKE Cluster
  ├── Namespace: default
  │   └── Envoy AI Gateway
  │       ├── Deployment: envoy-ai-gateway
  │       │   └── Container: envoy (listening on port 10000)
  │       │       └── Mounted ConfigMap: envoy-config (defines routing to Open WebUI)
  │       ├── Service: envoy-ai-gateway (port 10000)
  │       └── Ingress: envoy-ai-gateway (host: envoy.pool-side.cc)
  │
  ├── Namespace: ollama
  │   ├── Deployment: ollama
  │   │   └── Container: ollama (port 11434)
  │   ├── Service: ollama (exposes port 80 -> target port 11434)
  │   └── Ingress: ollama (host: ollama.pool-side.cc)
  │   └── PVC: ollama-models-pvc (persistent storage for models)
  │
  └── Namespace: openwebui
      ├── Deployment: openwebui
      │   └── Container: openwebui (port 80)
      ├── Service: openwebui (exposes port 80)
      └── Ingress: openwebui (host: openwebui.pool-side.cc)
``` 
