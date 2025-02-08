#!/bin/bash
set -euo pipefail

# deploy_springboot.sh
# This script deploys a Spring Boot application to AKS for PR/support builds and cleans up after the PR is complete.
#
# Usage:
#   ./deploy_springboot.sh deploy   - Deploys the application to the specified namespace.
#   ./deploy_springboot.sh cleanup  - Deletes the deployed application from the specified namespace.
#
# Environment Variables (optional, with defaults):
#   NAMESPACE   - Kubernetes namespace for deployment (default: pr-testing)
#   IMAGE_NAME  - Container image name to deploy (default: spring-boot-template)
#   IMAGE_TAG   - Container image tag (default: latest)
#
# Note: Ensure your kubeconfig is set appropriately (via KUBECONFIG or default location).

# Set defaults if variables are not set
NAMESPACE=${NAMESPACE:-pr-testing}
IMAGE_NAME=${IMAGE_NAME:-"spring-boot-template"}
IMAGE_TAG=${IMAGE_TAG:-"latest"}

# Define the deployment manifest as a heredoc.
# This manifest creates a simple deployment for a Spring Boot application.
read -r -d '' DEPLOYMENT_YAML <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: springboot-app
  labels:
    app: springboot-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: springboot-app
  template:
    metadata:
      labels:
        app: springboot-app
    spec:
      containers:
      - name: springboot-app
        image: ${IMAGE_NAME}:${IMAGE_TAG}
        ports:
        - containerPort: 8080
EOF

# Function to deploy the application.
deploy_app() {
  echo "Deploying Spring Boot application to AKS namespace '${NAMESPACE}'..."
  
  # Create namespace if it doesn't exist.
  if ! kubectl get namespace "${NAMESPACE}" >/dev/null 2>&1; then
    echo "Namespace '${NAMESPACE}' does not exist. Creating it..."
    kubectl create namespace "${NAMESPACE}"
  fi
  
  # Apply the deployment manifest.
  echo "$DEPLOYMENT_YAML" | kubectl apply -n "${NAMESPACE}" -f -
  
  # Wait for the deployment to complete rollout.
  echo "Waiting for deployment 'springboot-app' to rollout..."
  kubectl rollout status deployment/springboot-app -n "${NAMESPACE}" --timeout=120s
  
  echo "Deployment complete."
}

# Function to clean up the deployment.
cleanup_app() {
  echo "Cleaning up Spring Boot deployment from AKS namespace '${NAMESPACE}'..."
  
  # Delete the deployment (ignore if not found).
  kubectl delete deployment springboot-app -n "${NAMESPACE}" --ignore-not-found=true
  
  # Optionally, delete the namespace if it's solely used for PR deployments.
  # Uncomment the following lines if you wish to remove the namespace entirely.
  # echo "Deleting namespace '${NAMESPACE}'..."
  # kubectl delete namespace "${NAMESPACE}"
  
  echo "Cleanup complete."
}

# Main script logic: Check for the correct number of arguments.
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 [deploy|cleanup]"
  exit 1
fi

ACTION=$1

case "${ACTION}" in
  deploy)
    deploy_app
    ;;
  cleanup)
    cleanup_app
    ;;
  *)
    echo "Invalid action: ${ACTION}. Expected 'deploy' or 'cleanup'."
    exit 1
    ;;
esac
