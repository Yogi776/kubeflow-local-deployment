#!/bin/bash

###############################################################################
# Script: install-prerequisites.sh
# Description: Install required tools for Kubeflow Notebooks local setup
# Usage: ./scripts/install-prerequisites.sh
###############################################################################

set -e

# Enable debug mode if DEBUG=1
if [[ "${DEBUG}" == "1" ]]; then
    set -x
fi

echo "🚀 Installing Prerequisites for Kubeflow Notebooks..."
echo ""

# Detect OS
OS="$(uname -s)"
case "${OS}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    *)          MACHINE="UNKNOWN:${OS}"
esac

echo "📍 Detected OS: ${MACHINE}"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check Docker
echo "🐳 Checking Docker..."
if command_exists docker; then
    echo "✅ Docker is already installed: $(docker --version)"
else
    echo "❌ Docker is not installed!"
    echo "📥 Please install Docker Desktop from: https://www.docker.com/products/docker-desktop"
    echo "   For Mac: brew install --cask docker"
    exit 1
fi

# Verify Docker is running
echo "🔍 Verifying Docker is running..."
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is installed but not running!"
    echo "📍 Please start Docker Desktop and wait for it to be ready."
    echo "   1. Open Docker Desktop application"
    echo "   2. Wait for the green icon in menu bar"
    echo "   3. Run this script again"
    exit 1
fi

# Check Docker resources
echo "📊 Checking Docker resource allocation..."
DOCKER_MEM=$(docker info --format '{{.MemTotal}}' 2>/dev/null || echo 0)
if [ "$DOCKER_MEM" -lt 6442450944 ]; then  # Less than 6GB
    echo "⚠️  WARNING: Docker has less than 6GB RAM allocated"
    echo "   Recommended: At least 8GB RAM for Kubeflow"
    echo "   Current: ~$((DOCKER_MEM / 1024 / 1024 / 1024))GB"
    echo ""
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Please increase Docker resources in Docker Desktop → Settings → Resources"
        exit 1
    fi
fi
echo ""

# Install kubectl
echo "☸️  Checking kubectl..."
if command_exists kubectl; then
    echo "✅ kubectl is already installed: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
else
    echo "📥 Installing kubectl..."
    if [ "$MACHINE" = "Mac" ]; then
        if command_exists brew; then
            brew install kubectl
        else
            echo "Please install Homebrew first: https://brew.sh"
            exit 1
        fi
    elif [ "$MACHINE" = "Linux" ]; then
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
        rm kubectl
    fi
    echo "✅ kubectl installed successfully"
fi
echo ""

# Install Kind
echo "🎯 Checking Kind..."
if command_exists kind; then
    echo "✅ Kind is already installed: $(kind version)"
else
    echo "📥 Installing Kind..."
    if [ "$MACHINE" = "Mac" ]; then
        if command_exists brew; then
            brew install kind
        else
            curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-darwin-amd64
            chmod +x ./kind
            sudo mv ./kind /usr/local/bin/kind
        fi
    elif [ "$MACHINE" = "Linux" ]; then
        curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
        chmod +x ./kind
        sudo mv ./kind /usr/local/bin/kind
    fi
    echo "✅ Kind installed successfully"
fi
echo ""

# Install kustomize
echo "🔧 Checking kustomize..."
if command_exists kustomize; then
    echo "✅ kustomize is already installed: $(kustomize version --short 2>/dev/null || kustomize version)"
else
    echo "📥 Installing kustomize..."
    if [ "$MACHINE" = "Mac" ]; then
        if command_exists brew; then
            brew install kustomize
        else
            curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
            sudo mv kustomize /usr/local/bin/
        fi
    elif [ "$MACHINE" = "Linux" ]; then
        curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
        sudo mv kustomize /usr/local/bin/
    fi
    echo "✅ kustomize installed successfully"
fi
echo ""

echo "✨ All prerequisites installed successfully!"
echo ""
echo "📋 Summary:"
echo "   - Docker: $(docker --version)"
echo "   - kubectl: $(kubectl version --client --short 2>/dev/null || echo $(kubectl version --client))"
echo "   - Kind: $(kind version)"
echo "   - kustomize: $(kustomize version --short 2>/dev/null || echo $(kustomize version))"
echo ""
echo "🎯 Next step: Run './scripts/setup-kind-cluster.sh' to create your local Kubernetes cluster"

