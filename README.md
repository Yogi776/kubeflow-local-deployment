# Kubeflow Local Deployment

> 🚀 **Run Kubeflow Notebooks locally in minutes** - A production-ready local Kubeflow setup with full authentication bypass for development.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Kind](https://img.shields.io/badge/Kind-Kubernetes-326CE5)](https://kind.sigs.k8s.io/)
[![Kubeflow](https://img.shields.io/badge/Kubeflow-v1.9.0-blue)](https://www.kubeflow.org/)

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start-3-commands)
- [End-to-End Installation Flow](#-end-to-end-installation-flow)
- [Usage Guide](#-usage-guide)
- [Architecture](#-architecture)
- [Troubleshooting](#-troubleshooting)
- [Advanced Usage](#-advanced-usage)
- [Cleanup](#-cleanup)

---

## 🎯 Overview

This project provides a **complete local Kubeflow Notebooks deployment** running on Kind (Kubernetes in Docker). Perfect for:

- 🔬 **Local ML Development** - Full Jupyter notebook environment
- 🧪 **Testing Kubeflow** - Try before deploying to production
- 📚 **Learning Kubernetes** - Understand Kubeflow architecture
- 🎓 **Training & Demos** - No cloud costs, runs on your laptop

### What You Get

✅ **Full Kubeflow Stack**
- Central Dashboard UI
- Jupyter Notebooks (with Web UI)
- Volume Management
- Profile Controller (multi-user namespaces)

✅ **Production-Ready Infrastructure**
- Istio Service Mesh
- cert-manager for TLS
- Authentication bypass (local dev)
- Pre-configured user profile

✅ **Ready-to-Use Notebooks**
- Sample notebook pre-deployed
- Jupyter scipy stack
- 10GB persistent storage
- Resource limits configured

---

## 🔧 Prerequisites

### System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **RAM** | 8GB | 10-12GB |
| **CPU** | 2 cores | 4 cores |
| **Disk** | 20GB free | 30GB free |
| **OS** | macOS/Linux | macOS/Linux |

### Required Software

1. **Docker Desktop** (must be running)
   ```bash
   # Verify Docker is running
   docker info
   ```

2. **kubectl** (will auto-install if missing)
3. **kind** (will auto-install if missing)
4. **kustomize** (will auto-install if missing)

### Docker Configuration

**Important:** Allocate sufficient resources to Docker Desktop

```bash
# Docker Desktop → Settings → Resources
Memory: 10-12GB
CPUs: 4
Swap: 1GB
```

---

## ⚡ Quick Start (3 Commands)

```bash
# 1. Install prerequisites
make prerequisites

# 2. Install Kubeflow (takes ~10-15 minutes)
make install

# 3. Access the UI
make start
# Opens http://localhost:8081 automatically
```

That's it! Your Kubeflow environment is ready. 🎉

---

## 📖 End-to-End Installation Flow

### Step 1: Clone and Setup

```bash
# Clone the repository
git clone <your-repo-url>
cd kubeflow-local-deployment

# Verify Docker is running
docker info

# Install prerequisites (kubectl, kind, kustomize)
make prerequisites
```

**What happens:**
- ✅ Checks Docker availability
- ✅ Installs kubectl (Kubernetes CLI)
- ✅ Installs kind (Kubernetes in Docker)
- ✅ Installs kustomize (manifest management)

---

### Step 2: Create Kubernetes Cluster

```bash
make cluster
```

**What happens:**
- ✅ Creates a Kind cluster named `kubeflow-local`
- ✅ Configures port mappings (80 → host)
- ✅ Sets up networking for local access
- ✅ Verifies cluster is healthy

**Verify cluster:**
```bash
kind get clusters
# Should show: kubeflow-local

kubectl cluster-info
# Should show cluster running
```

---

### Step 3: Install Kubeflow (Main Installation)

```bash
make install
```

This is the comprehensive installation that includes:

#### 3.1 Infrastructure Components (~3-5 minutes)

**cert-manager** - TLS certificate management
```bash
# Deployed version: v1.12.0
# Namespace: cert-manager
# Components: cert-manager, webhook, cainjector
```

**Istio Service Mesh** - Networking and security
```bash
# Deployed version: v1.22.0
# Namespace: istio-system
# Components: istiod, ingress gateway
```

#### 3.2 Kubeflow Core Components (~3-5 minutes)

**Central Dashboard** - Main UI
```bash
# Namespace: kubeflow
# Access point: http://localhost:8081
```

**Profile Controller** - User namespace management
```bash
# Manages: User profiles and namespaces
# Auto-creates: kubeflow-user-example-com namespace
```

**Notebook Components** - Jupyter environment
```bash
# - Jupyter Web App: Notebook management UI
# - Notebook Controller: Lifecycle management
# - Volumes Web App: Storage management
```

#### 3.3 Authentication Configuration (~1-2 minutes)

For local development, authentication is simplified:

- ❌ JWT validation removed
- ❌ OAuth2 proxy bypassed
- ✅ Direct access enabled
- ✅ Auto-login as `user@example.com`

**What gets configured:**
```yaml
# EnvoyFilter injects user header automatically
kubeflow-userid: user@example.com

# RBAC permissions granted
- cluster-admin for default-editor
- edit for all authenticated users
```

#### 3.4 User Profile & Sample Notebook (~2-3 minutes)

**User Profile Creation:**
```yaml
Profile: kubeflow-user-example-com
Owner: user@example.com
Namespace: kubeflow-user-example-com
```

**Sample Notebook Deployment:**
```yaml
Name: my-notebook
Image: jupyter-scipy:v1.9.0
Resources:
  CPU: 0.5 (request) / 2 (limit)
  Memory: 1Gi (request) / 2Gi (limit)
Storage: 10Gi PVC
```

---

### Step 4: Access Kubeflow

```bash
make start
```

**What happens:**
- ✅ Verifies all components are ready
- ✅ Sets up port-forward to Istio gateway
- ✅ Opens browser to http://localhost:8081
- ✅ Auto-authenticates as user@example.com

**Access URL:** http://localhost:8081

**Browser opens automatically showing:**
- Central Dashboard
- Notebooks menu (left sidebar)
- Pre-deployed sample notebook

---

### Step 5: Verify Installation

```bash
# Check cluster status
make status

# View all components
make info
```

**Expected output:**
```bash
✅ Cluster 'kubeflow-local' running
✅ Kubeflow components (11 deployments)
✅ User namespace active
✅ Sample notebook running (2/2 containers)
```

**Verify manually:**
```bash
# Check Kubeflow pods
kubectl get pods -n kubeflow

# Check user namespace
kubectl get pods -n kubeflow-user-example-com

# Check notebook status
kubectl get notebooks -n kubeflow-user-example-com
```

---

## 🎮 Usage Guide

### Accessing Kubeflow Dashboard

1. **Start port-forward**
   ```bash
   make start
   ```

2. **Open browser**
   - URL: http://localhost:8081
   - No login required (auto-authenticated)

3. **Navigate to Notebooks**
   - Click "Notebooks" in left menu
   - See your notebooks listed

### Using the Sample Notebook

1. **Connect to notebook**
   ```bash
   # In Kubeflow UI:
   # 1. Click "Notebooks" menu
   # 2. Find "my-notebook"
   # 3. Click "CONNECT" button
   ```

2. **Jupyter opens in new tab**
   - Full Jupyter environment
   - scipy stack pre-installed
   - 10GB storage available

3. **Create your first notebook**
   ```python
   # test.ipynb
   import numpy as np
   import pandas as pd
   import matplotlib.pyplot as plt
   
   print("Hello from Kubeflow!")
   ```

### Creating New Notebooks

1. **Via Kubeflow UI**
   ```bash
   # 1. Click "Notebooks" → "+ New Notebook"
   # 2. Configure:
   #    - Name: my-ml-notebook
   #    - Image: jupyter-scipy:v1.9.0
   #    - CPU: 1.0, Memory: 2Gi
   #    - Workspace Volume: 10Gi
   # 3. Click "Launch"
   ```

2. **Via YAML manifest**
   ```yaml
   # my-custom-notebook.yaml
   apiVersion: kubeflow.org/v1
   kind: Notebook
   metadata:
     name: my-ml-notebook
     namespace: kubeflow-user-example-com
   spec:
     template:
       spec:
         containers:
         - name: notebook
           image: kubeflownotebookswg/jupyter-scipy:v1.9.0
           resources:
             requests:
               cpu: "1.0"
               memory: "2Gi"
   ```
   
   ```bash
   kubectl apply -f my-custom-notebook.yaml
   ```

### Managing Notebooks

```bash
# List notebooks
kubectl get notebooks -n kubeflow-user-example-com

# Get notebook details
kubectl describe notebook my-notebook -n kubeflow-user-example-com

# View notebook logs
kubectl logs -n kubeflow-user-example-com -l app=my-notebook

# Delete notebook
kubectl delete notebook my-notebook -n kubeflow-user-example-com
```

### Working with Volumes

```bash
# List persistent volumes
kubectl get pvc -n kubeflow-user-example-com

# Check volume usage
kubectl exec -it <pod-name> -n kubeflow-user-example-com -- df -h

# Backup notebook data
kubectl cp kubeflow-user-example-com/<pod-name>:/home/jovyan ./backup
```

### Stopping and Restarting

```bash
# Stop port-forward
make stop

# Restart access later
make start

# Check if everything is running
make status
```

---

## 🏗️ Architecture

### Component Layout

```
┌─────────────────────────────────────────────────┐
│              Docker Desktop                      │
│  ┌───────────────────────────────────────────┐  │
│  │         Kind Cluster                      │  │
│  │  ┌─────────────────────────────────────┐ │  │
│  │  │    istio-system namespace           │ │  │
│  │  │  - Istio Ingress Gateway           │ │  │
│  │  │  - istiod (control plane)          │ │  │
│  │  └─────────────────────────────────────┘ │  │
│  │  ┌─────────────────────────────────────┐ │  │
│  │  │    kubeflow namespace               │ │  │
│  │  │  - Central Dashboard                │ │  │
│  │  │  - Jupyter Web App                  │ │  │
│  │  │  - Notebook Controller              │ │  │
│  │  │  - Profile Controller               │ │  │
│  │  │  - Volumes Web App                  │ │  │
│  │  └─────────────────────────────────────┘ │  │
│  │  ┌─────────────────────────────────────┐ │  │
│  │  │  kubeflow-user-example-com          │ │  │
│  │  │  - my-notebook (Jupyter)            │ │  │
│  │  │  - PVC (10Gi storage)               │ │  │
│  │  └─────────────────────────────────────┘ │  │
│  └───────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
         │ Port-forward 8081:80
         ▼
    Browser → http://localhost:8081
```

### Network Flow

```
Browser (localhost:8081)
  │
  ├─→ kubectl port-forward
  │
  └─→ Istio Ingress Gateway (port 80)
       │
       ├─→ EnvoyFilter (injects user header)
       │
       └─→ Central Dashboard
            │
            ├─→ Jupyter Web App
            │    │
            │    └─→ Notebook Pods (user namespace)
            │
            └─→ Volumes Web App
```

### Authentication Flow (Local Dev)

```
Request → Istio Gateway
  │
  ├─→ EnvoyFilter (Lua script)
  │    │ Injects: kubeflow-userid: user@example.com
  │
  └─→ Central Dashboard
       │ Reads header
       │ No JWT validation
       │ No OAuth2 redirect
       │
       └─→ Direct access granted
```

---

## 🐛 Troubleshooting

### Installation Issues

#### Issue: "Docker daemon not running"
```bash
# Error: Cannot connect to Docker daemon

# Solution:
# 1. Open Docker Desktop
# 2. Wait for it to start completely
# 3. Verify:
docker info
```

#### Issue: "Insufficient memory"
```bash
# Error: Pods stuck in Pending state

# Solution:
# 1. Docker Desktop → Settings → Resources
# 2. Increase Memory to 10-12GB
# 3. Click "Apply & Restart"
# 4. Clean and reinstall:
make clean
make install
```

#### Issue: "Installation times out"
```bash
# Error: Timeout waiting for components

# Solution:
# 1. Check Docker resources
docker stats

# 2. Check pod events
kubectl get events -n kubeflow --sort-by='.lastTimestamp'

# 3. Retry specific component
kubectl rollout restart deployment/<name> -n kubeflow
```

#### Issue: "Port already in use"
```bash
# Error: Port 8081 already allocated

# Solution:
# 1. Find and kill process
lsof -ti:8081 | xargs kill -9

# 2. Or change port in Makefile
KUBEFLOW_PORT = 8082

# 3. Restart
make start
```

### Runtime Issues

#### Issue: "UI not loading"
```bash
# Browser shows connection refused

# Diagnosis:
make status

# Solutions:
# 1. Restart port-forward
make stop
make start

# 2. Check ingress gateway
kubectl get pods -n istio-system

# 3. Check dashboard
kubectl get pods -n kubeflow | grep centraldashboard

# 4. View logs
kubectl logs -n kubeflow deployment/centraldashboard
```

#### Issue: "Notebook won't start"
```bash
# Pod stuck in ContainerCreating

# Diagnosis:
kubectl describe pod <pod-name> -n kubeflow-user-example-com

# Common causes:
# 1. Image pull timeout - wait longer
# 2. No resources - increase Docker memory
# 3. PVC issues - check storage

kubectl get pvc -n kubeflow-user-example-com
```

#### Issue: "Can't connect to notebook"
```bash
# CONNECT button does nothing

# Solutions:
# 1. Check notebook status
kubectl get notebooks -n kubeflow-user-example-com

# 2. Verify pod is running (2/2)
kubectl get pods -n kubeflow-user-example-com

# 3. Check service
kubectl get svc -n kubeflow-user-example-com

# 4. Restart notebook via UI
# Delete and recreate the notebook
```

### Component Status Checks

```bash
# Overall cluster health
kubectl get nodes
kubectl get pods -A

# Kubeflow components
kubectl get deployments -n kubeflow
kubectl get pods -n kubeflow

# User namespace
kubectl get all -n kubeflow-user-example-com

# Istio gateway
kubectl get pods -n istio-system
kubectl get svc istio-ingressgateway -n istio-system

# Resource usage
kubectl top nodes
kubectl top pods -n kubeflow
```

### Log Analysis

```bash
# Dashboard logs
kubectl logs -n kubeflow deployment/centraldashboard --tail=50

# Notebook controller logs
kubectl logs -n kubeflow deployment/notebook-controller-deployment

# Profile controller logs
kubectl logs -n kubeflow deployment/profiles-deployment

# Istio gateway logs
kubectl logs -n istio-system deployment/istio-ingressgateway

# Notebook pod logs
kubectl logs -n kubeflow-user-example-com <notebook-pod-name> -c notebook
```

---

## 🔬 Advanced Usage

### Alternative: Fast Jupyter (Lightweight)

If you don't need the full Kubeflow stack:

```bash
# Quick Jupyter deployment (60 seconds)
make cluster
make fast-jupyter
make fast-start

# Access: http://localhost:8888
# Password: jupyter123
```

**Comparison:**

| Feature | Fast Jupyter | Full Kubeflow |
|---------|-------------|---------------|
| **Setup Time** | ~60 seconds | ~10-15 minutes |
| **RAM Required** | 2-4GB | 10-12GB |
| **UI** | Jupyter only | Full dashboard |
| **Authentication** | Password | Header injection |
| **Use Case** | Quick testing | Production-like |

### Custom Notebook Images

Available images:
```bash
# Minimal
kubeflownotebookswg/jupyter-scipy:v1.9.0

# TensorFlow
kubeflownotebookswg/jupyter-tensorflow-full:v1.9.0

# PyTorch
kubeflownotebookswg/jupyter-pytorch-full:v1.9.0

# CUDA (GPU support)
kubeflownotebookswg/jupyter-pytorch-cuda-full:v1.9.0
```

### Resource Customization

Edit notebook specs:
```yaml
spec:
  template:
    spec:
      containers:
      - name: notebook
        resources:
          requests:
            cpu: "2.0"        # Increase CPU
            memory: "4Gi"      # Increase memory
          limits:
            cpu: "4.0"
            memory: "8Gi"
```

### Adding Custom Python Packages

Method 1: Install in notebook
```bash
# In Jupyter terminal
pip install <package>
```

Method 2: Build custom image
```dockerfile
FROM kubeflownotebookswg/jupyter-scipy:v1.9.0
RUN pip install scikit-learn xgboost lightgbm
```

### Persistent Storage

```bash
# Check storage
kubectl get pvc -n kubeflow-user-example-com

# Expand volume (edit PVC)
kubectl edit pvc <pvc-name> -n kubeflow-user-example-com
# Change storage: 10Gi → 20Gi

# Backup data
kubectl cp kubeflow-user-example-com/<pod>:/home/jovyan ./backup
```

### Multi-User Setup

Create additional profiles:
```yaml
apiVersion: kubeflow.org/v1
kind: Profile
metadata:
  name: kubeflow-user-alice
spec:
  owner:
    kind: User
    name: alice@example.com
```

---

## 🗑️ Cleanup

### Partial Cleanup

```bash
# Stop port-forward only
make stop

# Delete notebooks only
kubectl delete notebooks --all -n kubeflow-user-example-com
```

### Full Cleanup

```bash
# Delete everything (cluster, resources, data)
make clean
```

**Warning:** This deletes:
- ❌ Kind cluster
- ❌ All Kubeflow components
- ❌ All notebooks and data
- ❌ All persistent volumes

**Backup important data first:**
```bash
kubectl cp kubeflow-user-example-com/<pod>:/home/jovyan ./backup
```

### Start Fresh

```bash
make clean
make install
```

---

## 📊 Useful Commands Reference

### Quick Commands
```bash
make help          # Show all commands
make prerequisites # Install required tools
make cluster       # Create Kubernetes cluster
make install       # Install Kubeflow (full)
make start         # Access UI at localhost:8081
make stop          # Stop port-forward
make status        # Check deployment status
make info          # Show access information
make clean         # Delete everything
```

### Fast Jupyter Commands
```bash
make fast-jupyter  # Deploy lightweight Jupyter
make fast-start    # Access at localhost:8888
```

### Kubernetes Commands
```bash
# Cluster
kubectl cluster-info
kind get clusters

# Pods
kubectl get pods -A
kubectl get pods -n kubeflow
kubectl get pods -n kubeflow-user-example-com

# Notebooks
kubectl get notebooks -n kubeflow-user-example-com
kubectl describe notebook <name> -n kubeflow-user-example-com

# Logs
kubectl logs -n kubeflow deployment/centraldashboard
kubectl logs -n kubeflow-user-example-com <pod-name>

# Resources
kubectl top nodes
kubectl top pods -n kubeflow

# Services
kubectl get svc -A
kubectl get svc -n istio-system
```

---

## 📚 Resources

- [Kubeflow Documentation](https://www.kubeflow.org/docs/)
- [Kubeflow Manifests GitHub](https://github.com/kubeflow/manifests)
- [Kind Documentation](https://kind.sigs.k8s.io/)
- [Kubectl Cheatsheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Istio Documentation](https://istio.io/latest/docs/)
- [Jupyter Docker Stacks](https://jupyter-docker-stacks.readthedocs.io/)

---

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## ✨ Features Summary

✅ **One-command installation** - `make install`  
✅ **Auto-authentication bypass** - No login needed  
✅ **Pre-configured notebooks** - Ready to use  
✅ **Production-like environment** - Full Istio + Kubeflow  
✅ **Lightweight alternative** - Fast Jupyter option  
✅ **Easy cleanup** - `make clean`  
✅ **Well documented** - Comprehensive guides  
✅ **Troubleshooting included** - Common issues covered  

---

## 🎓 Getting Started Checklist

- [ ] Docker Desktop installed and running (10-12GB RAM)
- [ ] Run `make prerequisites`
- [ ] Run `make install` (wait ~10-15 minutes)
- [ ] Run `make start` (opens browser)
- [ ] Click "Notebooks" → "CONNECT" on my-notebook
- [ ] Create your first Jupyter notebook
- [ ] 🎉 Start building ML projects!

---

**Need help?** Check the [Troubleshooting](#-troubleshooting) section or [open an issue](../../issues).

**Happy Machine Learning! 🚀**