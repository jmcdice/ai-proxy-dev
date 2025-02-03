#!/usr/bin/env bash
set -e
source env.sh

function create_cluster() {
  echo "Creating GKE cluster '$CLUSTER_NAME'..."
  gcloud container clusters create "$CLUSTER_NAME" \
    --zone "$ZONE" \
    --num-nodes "$NUM_NODES" \
    --machine-type "$MACHINE_TYPE" \
    --enable-autoupgrade \
    --enable-autorepair \
    --release-channel "regular" \
    --scopes cloud-platform
}

function create_gpu_node_pool() {
  echo "Creating GPU node pool 'gpu-pool'..."
  gcloud container node-pools create "gpu-pool" \
    --cluster "$CLUSTER_NAME" \
    --zone "$ZONE" \
    --machine-type "g2-standard-4" \
    --accelerator "type=nvidia-l4,count=1" \
    --num-nodes 1 \
    --enable-autoupgrade \
    --enable-autorepair \
    --node-taints "nvidia.com/gpu=present:NoSchedule" \
    --image-type="COS_CONTAINERD" \
    --scopes "https://www.googleapis.com/auth/cloud-platform"
}

function get_cluster_credentials() {
  echo "Fetching cluster credentials..."
  gcloud container clusters get-credentials "$CLUSTER_NAME" --zone "$ZONE"
}

function wait_for_nodes_ready() {
  echo "Waiting for all nodes to be Ready..."
  local not_ready=true
  local timeout=1800  # 30 minutes timeout
  local start_time=$(date +%s)
  
  while $not_ready; do
    current_time=$(date +%s)
    elapsed_time=$((current_time - start_time))
    
    if [ $elapsed_time -gt $timeout ]; then
      echo "Timeout waiting for nodes to be ready after 30 minutes"
      return 1
    fi
    
    not_ready_nodes=$(kubectl get nodes --no-headers | grep -v " Ready" | wc -l)
    if [ "$not_ready_nodes" -eq 0 ]; then
      not_ready=false
    else
      echo "Waiting... ($not_ready_nodes node(s) not Ready, elapsed time: ${elapsed_time}s)"
      sleep 10
    fi
  done
  echo "All nodes are Ready."
}

function main() {
  create_cluster
  create_gpu_node_pool
  get_cluster_credentials
  wait_for_nodes_ready
  echo "Cluster setup complete."
}

# Execute main (or call individual functions as needed)
main
