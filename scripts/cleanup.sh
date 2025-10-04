#!/bin/bash

###############################################################################
# Script: cleanup.sh
# Description: Clean up Kubeflow Notebooks local setup
# Usage: ./scripts/cleanup.sh
###############################################################################

set -e

CLUSTER_NAME="kubeflow-local"

echo "🧹 Cleaning up Kubeflow Notebooks setup..."
echo ""

# Confirm deletion
read -p "⚠️  This will delete the entire '${CLUSTER_NAME}' cluster. Are you sure? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Cleanup cancelled"
    exit 1
fi

# Check if cluster exists
if kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
    echo "🗑️  Deleting Kind cluster '${CLUSTER_NAME}'..."
    kind delete cluster --name "${CLUSTER_NAME}"
    echo "✅ Cluster deleted"
else
    echo "ℹ️  Cluster '${CLUSTER_NAME}' not found, nothing to delete"
fi

# Clean up temp files
if [ -d "/tmp/kubeflow-manifests" ]; then
    echo "🗑️  Cleaning up temporary files..."
    rm -rf /tmp/kubeflow-manifests
    echo "✅ Temporary files cleaned"
fi

echo ""
echo "✨ Cleanup complete!"
echo ""
echo "💡 To start again, run:"
echo "   ./scripts/setup-kind-cluster.sh"

