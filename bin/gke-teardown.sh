#!/usr/bin/env bash
set -e

source env.sh

echo "Deleting GKE cluster '$CLUSTER_NAME' in zone '$ZONE'..."
gcloud container clusters delete "$CLUSTER_NAME" --zone "$ZONE" --quiet

echo "Cluster teardown complete."
