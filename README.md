# AI Gateway Demo Environment

An on-demand demo environment running on Google Kubernetes Engine (GKE) that showcases a Cloud Native Large Language Model (LLM) gateway. This environment features multiple AI services integrated through a unified Envoy gateway, designed for efficient spin-up and tear-down to optimize costs.

## Features

- **GKE Cluster with GPU Support**
  - Dedicated GPU-enabled node pool (NVIDIA Tesla K80/T4 GPUs)
  - Automatic NVIDIA driver installation
  - Standard node pool for non-GPU workloads

- **Intelligent Request Routing**
  - Envoy-based gateway serving as a reverse proxy
  - Unified API interface for all AI services
  - Efficient request management and distribution

- **Integrated AI Services**
  - Ollama with persistent model storage
  - Open WebUI for interactive access
  - Conductor demo application showcasing multi-backend integration:
    - OpenAI (GPT-4) integration
    - Ollama (DeepSeek R1) endpoint
    - Anthropic model support

- **Cost-Efficient Design**
  - On-demand deployment and teardown
  - Resource optimization
  - Pay only for active demo time

## Project Structure

```
.
├── README.md
├── bin/
│   ├── build_conductor.sh    # Conductor image build script
│   ├── deploy-ollama.sh      # Ollama deployment script
│   ├── deploy-openwebui.sh   # Open WebUI deployment script
│   ├── gke-deploy.sh         # GKE cluster creation script
│   └── gke-teardown.sh       # Cleanup script
├── docs/
│   ├── arch.md              # Architecture documentation
│   ├── envoy-arch.md        # Envoy configuration details
│   ├── notes.md             # Additional context
│   └── test.md             # Testing procedures
├── env.sh                   # Environment configuration
└── k8s/
    ├── conductor/          # Demo application
    │   ├── Dockerfile
    │   ├── app.py
    │   └── requirements.txt
    ├── ollama/            # Ollama K8s manifests
    │   ├── cert-ollama.yml
    │   ├── deployment-ollama.yml
    │   ├── ingress-ollama.yml
    │   ├── namespace-ollama.yaml
    │   ├── service-ollama.yml
    │   └── storage-ollama.yml
    └── openwebui/         # Open WebUI K8s manifests
        ├── cert-owui.yml
        ├── deployment-owui.yml
        ├── ingress-owui.yml
        ├── namespace-owui.yml
        └── service-owui.yml
```

## System Architecture

1. **Cluster Initialization**
   - GKE cluster creation with GPU node pool
   - Network configuration

2. **Service Deployment**
   - Ollama and Open WebUI deployment (done)
   - Envoy gateway configuration (done)
     - openai (done)
     - AWS    (done, not tested)
     - ollama (done)
   - Conductor demo app setup (todo)

3. **Request Flow**
   - External requests route through `envoy.pool-side.cc`
   - Envoy gateway handles request distribution
   - Backend services process requests
   - Response aggregation and return

## Prerequisites

- GCP account with appropriate permissions
- Installed and configured tools:
  - `gcloud` CLI
  - Docker
  - `kubectl`
- Configured Artifact Registry repository

## Getting Started

1. **Environment Setup**
   ```bash
   # Edit environment configuration
   vim env.sh

   # Deploy GKE cluster
   ./bin/gke-deploy.sh
   ```

2. **Service Deployment**
   ```bash
   # Deploy AI services
   ./bin/deploy-ollama.sh
   ./bin/deploy-openwebui.sh

   # Build and deploy Conductor (todo)
   ./bin/build_conductor.sh


```console
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

3. **Verification**
   - Access the Envoy gateway at `envoy.pool-side.cc`
   - Use Conductor to test AI endpoints
   - Monitor logs for proper routing

## Cleanup

```bash
# Remove all resources
./bin/gke-teardown.sh
```

## Contributing

This project is under active development. Future updates will include:
- Enhanced Envoy gateway deployment
- Additional testing scenarios
- Performance optimization guides

