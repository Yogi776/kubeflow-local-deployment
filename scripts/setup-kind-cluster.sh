#!/bin/bash

###############################################################################
# Script: setup-kind-cluster.sh
# Description: Create a Kind cluster for Kubeflow Notebooks
# Usage: ./scripts/setup-kind-cluster.sh
###############################################################################

set -e

CLUSTER_NAME="kubeflow-local"

echo "🎯 Setting up Kind cluster for Kubeflow Notebooks..."
echo ""

# Check if cluster already exists
if kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
    echo "⚠️  Cluster '${CLUSTER_NAME}' already exists!"
    read -p "Do you want to delete and recreate it? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🗑️  Deleting existing cluster..."
        kind delete cluster --name "${CLUSTER_NAME}"
    else
        echo "✅ Using existing cluster"
        exit 0
    fi
fi

echo "📝 Creating Kind cluster configuration..."

# Create Kind cluster config
cat > /tmp/kind-config.yaml <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: ${CLUSTER_NAME}
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 8080
    protocol: TCP
  - containerPort: 443
    hostPort: 8443
    protocol: TCP
EOF

echo "🚀 Creating Kind cluster '${CLUSTER_NAME}'..."
kind create cluster --config /tmp/kind-config.yaml --wait 5m

echo ""
echo "🔍 Verifying cluster..."
kubectl cluster-info --context kind-${CLUSTER_NAME}

echo ""
echo "📊 Cluster nodes:"
kubectl get nodes

echo ""
echo "✅ Kind cluster '${CLUSTER_NAME}' created successfully!"
echo ""
echo "🎯 Next step: Run './scripts/install-kubeflow-notebooks.sh' to install Kubeflow Notebooks"

