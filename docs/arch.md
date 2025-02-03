# Project Architecture

## File Structure
```
k8s/
├── conductor/                    # Python-based management service
│   ├── Dockerfile
│   ├── app.py
│   └── requirements.txt
├── envoy-ai-gateway/            # AI Gateway for model routing
│   ├── config/
│   │   ├── base/               # Core gateway configuration
│   │   └── ollama/             # Ollama backend integration
│   ├── routes/                 # Model routing rules
│   └── scripts/                # Deployment and test utilities
├── ollama/                      # Local LLM serving
│   ├── deployment configs      # K8s resources for Ollama
│   └── tests/                  # Model testing scripts
└── openwebui/                   # Web UI for model interaction
    └── deployment configs      # K8s resources for OpenWebUI

## Kubernetes Cluster Architecture
```
GKE Cluster
├── System Namespaces
│   ├── kube-system              # Core K8s components
│   ├── kube-public              # Publicly readable resources
│   └── kube-node-lease          # Node heartbeats
├── GKE Managed Namespaces
│   ├── gke-managed-system
│   ├── gke-managed-cim
│   ├── gmp-system
│   ├── gmp-public
│   └── gke-managed-volumepopulator
├── AI Gateway Infrastructure
│   ├── envoy-gateway-system/    # Core Envoy Gateway
│   │   └── Deployments
│   │       └── envoy-gateway    # Envoy proxy instances
│   └── envoy-ai-gateway-system/ # AI Gateway Controller
│       └── Deployments
│           └── ai-gateway-controller
├── Model Serving (default)
│   ├── Gateway                  # Entry point for model requests
│   ├── Routes                   # Model routing rules
│   │   ├── OpenAI routes
│   │   ├── AWS routes
│   │   └── Ollama routes
│   └── Backends                 # Model endpoints
│       ├── OpenAI backend
│       ├── AWS backend          # Not active
│       └── Ollama backend
├── Ollama Namespace
│   ├── Deployment              # Ollama model server
│   ├── Service                 # Internal network endpoint
│   ├── Ingress                 # External access
│   └── Storage                 # Model weights persistence
└── OpenWebUI Namespace
    ├── Deployment             # Web interface
    ├── Service                # Internal endpoint
    ├── Ingress                # External access
    └── Volume                 # UI state persistence
```

## Data Flow
```
External Request
     │
     ▼
Ingress/Gateway
     │
     ├─────────────────┐
     ▼                 ▼
OpenWebUI         AI Gateway
     │                 │
     │            Model Routes
     │            ┌────┴────┐
     │            ▼         ▼
     │         OpenAI     Ollama
     │                     ▲
     └─────────────────────┘
```


