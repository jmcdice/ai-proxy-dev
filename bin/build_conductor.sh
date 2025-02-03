#!/usr/bin/env bash
set -e

# Source environment variables from env.sh
# Adjust the path if your env.sh isn't in the same directory as this script.
source ../env.sh

# Use environment variables from env.sh, or fallback to defaults
REGION="${REGION:-us-central1}"
PROJECT="${PROJECT:-socialmind-ai}"
REPOSITORY="${REPOSITORY:-conductor-demo}"
IMAGE_NAME="${IMAGE_NAME:-conductor-service}"
TAG="${TAG:-latest}"

# Construct the full image URI for Artifact Registry
IMAGE_URI="${REGION}-docker.pkg.dev/${PROJECT}/${REPOSITORY}/${IMAGE_NAME}:${TAG}"

echo "Building Docker image ${IMAGE_URI}..."
docker build -t "${IMAGE_URI}" .

echo "Pushing Docker image ${IMAGE_URI}..."
docker push "${IMAGE_URI}"

echo "Build and push complete."


