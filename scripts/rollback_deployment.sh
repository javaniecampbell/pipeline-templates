#!/bin/bash
set -euo pipefail

# rollback_deployment.sh
# This script performs a rollback by reading the artifact metadata file and updating
# the Kubernetes deployment to use the previous, known-good image tag.

# Usage: ./rollback_deployment.sh <deployment_name> <namespace> <metadata_file>
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <deployment_name> <namespace> <metadata_file>"
  exit 1
fi

DEPLOYMENT_NAME=$1
NAMESPACE=$2
METADATA_FILE=$3

# Read imageTag from the metadata file
if [ ! -f "$METADATA_FILE" ]; then
  echo "Metadata file $METADATA_FILE not found!"
  exit 1
fi

IMAGE_TAG=$(jq -r '.imageTag' "$METADATA_FILE")

if [ -z "$IMAGE_TAG" ] || [ "$IMAGE_TAG" == "null" ]; then
  echo "Failed to extract imageTag from metadata."
  exit 1
fi

echo "Rolling back deployment '$DEPLOYMENT_NAME' in namespace '$NAMESPACE' to image tag: $IMAGE_TAG"

# Patch the deployment to update the container image (assuming one container per pod)
kubectl set image deployment/"$DEPLOYMENT_NAME" "$DEPLOYMENT_NAME"="${IMAGE_TAG}" -n "$NAMESPACE"

# Optionally, wait for the rollout to complete
kubectl rollout status deployment/"$DEPLOYMENT_NAME" -n "$NAMESPACE" --timeout=120s

echo "Rollback complete."
