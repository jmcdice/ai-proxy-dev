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
  ├── README.md
  ├── bin
  │   ├── build_conductor.sh
  │   ├── deploy-envoy-ai-gw.sh
  │   ├── deploy-ollama.sh
  │   ├── deploy-openwebui.sh
  │   ├── gke-deploy.sh
  │   ├── gke-teardown.sh
  │   ├── gpu.sh
  │   ├── test-oai.sh
  │   └── test-ollama.sh
  ├── docs
  │   ├── add_ollama_model.md
  │   ├── arch.md
  │   ├── envoy-arch.md
  │   ├── notes.md
  │   └── test.md
  ├── k8s
  │   ├── conductor
  │   │   ├── Dockerfile
  │   │   ├── app.py
  │   │   └── requirements.txt
  │   ├── envoy-ai-gateway
  │   │   ├── config
  │   │   │   ├── base
  │   │   │   │   └── basic.yaml
  │   │   │   └── ollama
  │   │   │       ├── backend.yml
  │   │   │       └── secret.yml
  │   │   ├── delete_all.sh
  │   │   ├── routes
  │   │   │   └── routes.yml
  │   │   └── scripts
  │   │       └── secret.sh
  │   ├── ollama
  │   │   ├── backend-config-ollama.yaml
  │   │   ├── cert-ollama.yaml
  │   │   ├── deployment-ollama.yaml
  │   │   ├── ingress-ollama.yaml
  │   │   ├── namespace-ollama.yaml
  │   │   ├── service-ollama.yaml
  │   │   ├── storage-ollama.yaml
  │   │   └── tests
  │   │       ├── ollama-chat.sh
  │   │       ├── ollama-emb.sh
  │   │       └── ollama-gen.sh
  │   └── openwebui
  │       ├── backend-config-owui.yml
  │       ├── cert-owui.yml
  │       ├── deployment-owui.yml
  │       ├── ingress-owui.yml
  │       ├── namespace-owui.yml
  │       ├── service-owui.yml
  │       └── vol-owui.yml
  └── 
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

   # Deploy gateway with Ollama support
   ./bin/deploy-envoy-ai-gw.sh
```

### Architecture Diagram

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
OpenWebUI         Envoy AI Gateway
     │                 │
     │            Model Routes
     │            ┌────┴────┐
     │            ▼         ▼
     │         OpenAI     Ollama (local)
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
