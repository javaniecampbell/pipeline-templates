#!/bin/bash
# rollback_using_blob.sh
# Usage: ./rollback_using_blob.sh <storage_account> <container> <blob_name> <deployment_name> <namespace>
if [ "$#" -ne 5 ]; then
  echo "Usage: $0 <storage_account> <container> <blob_name> <deployment_name> <namespace>"
  exit 1
fi

STORAGE_ACCOUNT=$1
CONTAINER=$2
BLOB_NAME=$3
DEPLOYMENT_NAME=$4
NAMESPACE=$5

# Download the metadata file
az storage blob download \
  --account-name $STORAGE_ACCOUNT \
  --container-name $CONTAINER \
  --name $BLOB_NAME \
  --file downloaded-metadata.json \
  --auth-mode login

# Now, use jq to extract the image tag from the downloaded metadata file
IMAGE_TAG=$(jq -r '.imageTag' downloaded-metadata.json)

if [ -z "$IMAGE_TAG" ] || [ "$IMAGE_TAG" == "null" ]; then
  echo "Failed to extract image tag from metadata."
  exit 1
fi

echo "Rolling back deployment '$DEPLOYMENT_NAME' in namespace '$NAMESPACE' to image tag: $IMAGE_TAG"
kubectl set image deployment/"$DEPLOYMENT_NAME" "$DEPLOYMENT_NAME"="$IMAGE_TAG" -n "$NAMESPACE"
kubectl rollout status deployment/"$DEPLOYMENT_NAME" -n "$NAMESPACE" --timeout=120s
echo "Rollback complete."
