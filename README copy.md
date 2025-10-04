# Kubeflow Notebooks Local Setup

Run Kubeflow Notebooks locally with a complete end-to-end installation script!

## ✨ Key Features

- 🚀 **One-command installation** - Complete Kubeflow setup in 10-15 minutes
- 🔓 **No authentication required** - Direct access with no login screens
- 📊 **Full Kubeflow dashboard** - Complete UI for managing notebooks
- 🎯 **Pre-configured sample notebook** - Ready to use immediately
- ⚡ **Auto port-forwarding** - Browser opens automatically
- 🧹 **Easy cleanup** - One command to remove everything

## 🎯 Choose Your Setup

**Option 1: Full Kubeflow (Recommended)**
- Complete Kubeflow installation with UI
- Manage multiple notebooks
- Full features and dashboard
- Requires: 10-12GB RAM

**Option 2: Fast Jupyter (Quick Testing)**
- Lightweight standalone Jupyter
- Deploys in ~60 seconds
- Minimal resources (2-4GB RAM)
- No UI, direct Jupyter access

## 🚀 Quick Start (Full Kubeflow)

### One Command Installation

```bash
make install
```

This single command installs everything:
- ✅ Creates Kubernetes cluster
- ✅ Installs Istio service mesh
- ✅ Installs Kubeflow components
- ✅ Configures direct access (no authentication)
- ✅ Deploys sample notebook
- ✅ **~10-15 minutes total**

### Access Your Notebooks

```bash
make start
```

Opens `http://localhost:8081` with:
- ✅ **No login screen** - Direct access to dashboard
- ✅ **No username or password required**
- ✅ **No authentication prompts**
- ✅ Full Kubeflow dashboard instantly accessible
- ✅ Notebooks menu with your notebook ready to connect

### Common Commands

```bash
make help      # Show all available commands
make start     # Access Kubeflow UI at http://localhost:8081
make stop      # Stop port-forward
make status    # Check deployment status
make info      # Show access information
make clean     # Delete everything and start fresh
```

## ⚡ Quick Start (Fast Jupyter)

For lightweight testing without full Kubeflow:

```bash
make cluster         # Create Kubernetes cluster
make fast-jupyter    # Deploy Jupyter (~60 seconds)
make fast-start      # Access at http://localhost:8888
```

**Password:** `jupyter123`

## Overview

Kubeflow Notebooks provides a way to run web-based development environments (Jupyter notebooks) on Kubernetes. This setup uses **Kind (Kubernetes in Docker)** for a local Kubernetes cluster.

### 🔓 Authentication Setup

This local development setup is configured for **direct access** with no authentication barriers:

- ✅ **No Dex authentication** - Removed for simplicity
- ✅ **No OAuth2 login** - Eliminated authentication prompts
- ✅ **No username/password** - Direct access to all features
- ✅ **Auto-configured user identity** - System automatically identifies you as `user@example.com`
- ⚠️ **Local development only** - Do not use this configuration in production

**How it works:** An EnvoyFilter automatically injects user headers, and authorization policies are set to allow-all, giving you instant access to the Kubeflow dashboard without any login screens.

## Prerequisites

Before starting, ensure you have the following installed:

- **Docker Desktop** (for Mac/Windows) or Docker Engine (for Linux)
- **kubectl** - Kubernetes command-line tool
- **Kind** - Kubernetes in Docker
- **kustomize** - Kubernetes configuration management tool

## 📋 Manual Installation (Advanced)

If you prefer manual control over each step:

### Step 1: Install Prerequisites

```bash
make prerequisites
# or: ./scripts/install-prerequisites.sh
```

Installs Docker, kubectl, kind, and kustomize.

### Step 2: Create Kubernetes Cluster

```bash
make cluster
# or: ./scripts/setup-kind-cluster.sh
```

Creates a Kind cluster named `kubeflow-local`.

### Step 3: Install Kubeflow

```bash
make install
# or: ./scripts/install-kubeflow.sh
```

Installs all Kubeflow components (10-15 minutes).

### Step 4: Access the Dashboard

```bash
make start
```

Opens `http://localhost:8081`

## What You Can Do

Once setup is complete, you can:

1. **Create Jupyter Notebooks** - Launch various notebook servers (TensorFlow, PyTorch, etc.)
2. **Experiment with ML** - Run machine learning experiments in isolated environments
3. **Access GPUs** - Configure GPU access for training (if available)
4. **Customize Images** - Use custom Docker images for your notebooks
5. **Manage Resources** - Control CPU/Memory allocation per notebook

## Architecture

```
┌─────────────────────────────────────────┐
│         Your Local Machine              │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │   Docker                          │ │
│  │                                   │ │
│  │  ┌─────────────────────────────┐ │ │
│  │  │  Kind Cluster               │ │ │
│  │  │                             │ │ │
│  │  │  ┌──────────────────────┐   │ │ │
│  │  │  │ Kubeflow Notebooks   │   │ │ │
│  │  │  │  - Controller        │   │ │ │
│  │  │  │  - Web App UI        │   │ │ │
│  │  │  │  - Notebook Servers  │   │ │ │
│  │  │  └──────────────────────┘   │ │ │
│  │  └─────────────────────────────┘ │ │
│  └───────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

## Useful Commands

### Quick Status Check
```bash
make status    # Check everything at once
```

### Cluster Management
```bash
kubectl cluster-info --context kind-kubeflow-local  # Cluster info
kubectl get pods -n kubeflow                         # Kubeflow components
kubectl get notebooks -n kubeflow-user-example-com   # Your notebooks
```

### Access Kubeflow UI
```bash
make start     # Start port-forward and open browser
make stop      # Stop port-forward
make info      # Show access information
```

### Managing Notebooks
```bash
# View notebooks
kubectl get notebooks -n kubeflow-user-example-com

# Delete a notebook
kubectl delete notebook <notebook-name> -n kubeflow-user-example-com

# View notebook pod logs
kubectl logs <notebook-pod-name> -n kubeflow-user-example-com
```

## Troubleshooting

### Installation Failed
```bash
# Check the error messages in the installation script
# Most common issues:
# 1. Docker not running
# 2. Insufficient Docker memory (need 10-12GB)
# 3. Network timeouts

# Clean up and try again
make clean
make install
```

### UI Not Loading
```bash
# Check if port-forward is running
make status

# Restart port-forward
make stop
make start

# Check if Kubeflow components are ready
kubectl get pods -n kubeflow

# Wait a few seconds for services to be ready
# The UI should load directly without any login screen
```

### Out of Resources / Pods Pending
```bash
# Increase Docker resources in Docker Desktop:
# Settings → Resources → Memory: 10-12GB
# Settings → Resources → CPUs: 4+

# Then restart Docker and reinstall
make clean
make install
```

### Port Already in Use
```bash
# Kill existing port-forwards
make stop

# Or manually:
pkill -9 -f "port-forward"

# Then start again
make start
```

## Cleanup

To remove everything and start fresh:

```bash
make clean
```

This will:
- Delete the Kind cluster
- Remove all Kubeflow resources
- Clean up Docker containers
- Free up system resources

**Note:** Your notebooks and data will be deleted. Back up any important work first!

## ❓ Frequently Asked Questions

### Do I need a username and password?

**No!** This setup is configured for direct access with no authentication:
- No login screen
- No username required
- No password required
- Browser opens directly to the dashboard

### Why is there no authentication?

For **local development**, authentication adds unnecessary complexity. This setup:
- Uses EnvoyFilter to automatically inject user identity
- Sets authorization policies to allow-all
- Skips Dex and OAuth2 installation entirely
- Provides instant access for faster development

⚠️ **Important:** This configuration is **only for local development**. Never use this setup in production!

### What user am I logged in as?

You're automatically identified as `user@example.com`. This is configured via:
- EnvoyFilter injecting the `kubeflow-userid` header
- Central Dashboard accepting the header as authentication
- RBAC policies granting appropriate permissions

### Can I add real authentication?

If you need authentication for a shared environment, you'll need to:
1. Re-enable Dex installation in `scripts/install-kubeflow.sh` (Step 6)
2. Remove the authentication bypass configuration (Step 11)
3. Configure proper OAuth2 providers and user credentials

However, for single-user local development, authentication is unnecessary.

## Next Steps

1. **Explore the Notebooks UI** - Create your first notebook server
2. **Try ML Examples** - Run TensorFlow or PyTorch examples
3. **Customize Images** - Build custom notebook images for your needs
4. **Integrate with Pipelines** - Connect to Kubeflow Pipelines (optional)

## References

- [Kubeflow Notebooks Documentation](https://www.kubeflow.org/docs/components/notebooks/overview/)
- [Kubeflow Installation Guide](https://www.kubeflow.org/docs/started/installing-kubeflow/)
- [Kind Documentation](https://kind.sigs.k8s.io/)
- [Kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

## Support

For issues or questions:
- Kubeflow Slack: [kubeflow.slack.com](https://kubeflow.slack.com)
- GitHub Issues: [kubeflow/notebooks](https://github.com/kubeflow/notebooks/issues)

