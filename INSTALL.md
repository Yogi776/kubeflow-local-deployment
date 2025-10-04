# Kubeflow Installation Guide

## 🚀 One-Command Installation

The easiest way to get started:

```bash
make install
```

This single command:
1. ✅ Creates a local Kubernetes cluster (Kind)
2. ✅ Installs cert-manager for TLS
3. ✅ Installs Istio service mesh
4. ✅ Installs Dex + OAuth2 for authentication
5. ✅ Installs Kubeflow core components
6. ✅ Installs Central Dashboard UI
7. ✅ Installs Profile Controller
8. ✅ Installs Notebook components (Jupyter Web App, Controller, Volumes)
9. ✅ Configures authentication for local development
10. ✅ Creates user profile (user@example.com)
11. ✅ Deploys sample notebook
12. ✅ Verifies everything is working

**Time:** ~10-15 minutes  
**Requirements:** 10-12GB RAM, Docker Desktop running

---

## 📊 Step-by-Step Process

If you want to understand what happens during installation:

### Step 1: Prerequisites Check
```bash
make prerequisites
```

Installs and verifies:
- Docker Desktop (must be running)
- kubectl (Kubernetes CLI)
- Kind (Kubernetes in Docker)
- kustomize (Config management)

### Step 2: Create Cluster
```bash
make cluster
```

Creates a Kind cluster with:
- Cluster name: `kubeflow-local`
- Port mappings for services
- Resource limits configured

### Step 3: Install Kubeflow
```bash
make install
```

Runs the automated installation script that installs all components.

### Step 4: Access Dashboard
```bash
make start
```

Opens `http://localhost:8081` with:
- Auto-authentication as user@example.com
- Full navigation menu
- Ready-to-use notebook

---

## 🎯 What Gets Installed

### Core Infrastructure
- **cert-manager** - TLS certificate management
- **Istio** - Service mesh for networking
- **Dex** - OpenID Connect provider
- **OAuth2 Proxy** - Authentication gateway

### Kubeflow Components
- **Central Dashboard** - Main UI
- **Profile Controller** - User namespace management
- **Jupyter Web App** - Notebook UI
- **Notebook Controller** - Notebook lifecycle
- **Volumes Web App** - Storage management

### Pre-configured Resources
- **User Profile** - kubeflow-user-example-com
- **Sample Notebook** - my-notebook (jupyter-scipy image)
- **PVC** - 10Gi storage for notebook data

---

## 🔧 Configuration Details

### Authentication
- **Method:** Header injection (local dev only)
- **User:** user@example.com
- **No password required** - auto-authenticated
- **RBAC:** Cluster-admin access granted

### Networking
- **UI Port:** 8081
- **Istio Gateway:** Port 80 (internal)
- **Port-forward:** Automatic via `make start`

### Resources
- **Notebook:** 0.5 CPU, 1GB RAM (request)
- **Notebook:** 2 CPU, 2GB RAM (limit)
- **Storage:** 10Gi PVC per notebook

---

## ⚡ Alternative: Fast Jupyter

If you just need a quick Jupyter environment without full Kubeflow:

```bash
make cluster         # Create cluster
make fast-jupyter    # Deploy Jupyter in 60 seconds
make fast-start      # Access at http://localhost:8888
```

**Features:**
- Minimal resources (256Mi RAM, 100m CPU)
- No authentication complexity
- Direct Jupyter access
- Password: `jupyter123`
- Perfect for testing

---

## 🔍 Verification

Check installation status:

```bash
make status
```

Shows:
- Cluster status
- Kubeflow components
- Notebook pods
- Port-forward status

Get access information:

```bash
make info
```

Shows:
- Access URL
- Authentication details
- Current deployment status

---

## 🐛 Troubleshooting

### Installation Fails
```bash
# Check Docker is running
docker info

# Check Docker memory
# Docker Desktop → Settings → Resources → Memory (needs 10-12GB)

# Clean up and retry
make clean
make install
```

### UI Not Loading
```bash
# Check port-forward
make status

# Restart port-forward
make stop
make start
```

### Components Not Ready
```bash
# Check pod status
kubectl get pods -n kubeflow
kubectl get pods -n istio-system
kubectl get pods -n auth

# View logs
kubectl logs -n kubeflow deployment/centraldashboard
```

### Out of Memory
```bash
# Increase Docker memory to 12GB
# Docker Desktop → Settings → Resources

# Restart Docker
# Then clean and reinstall
make clean
make install
```

---

## 🗑️ Cleanup

Remove everything:

```bash
make clean
```

This deletes:
- Kind cluster
- All Kubeflow resources
- Docker containers
- Port-forwards

**Warning:** All notebook data will be lost!

---

## 📝 Useful Commands

### Management
```bash
make help      # Show all commands
make status    # Check deployment
make start     # Access UI
make stop      # Stop port-forward
make info      # Show access info
make clean     # Delete everything
```

### Kubernetes
```bash
# View all pods
kubectl get pods -A

# View Kubeflow components
kubectl get all -n kubeflow

# View your notebooks
kubectl get notebooks -n kubeflow-user-example-com

# View logs
kubectl logs -n kubeflow deployment/centraldashboard
```

---

## 🎓 Next Steps

After installation:

1. **Access Dashboard:** `make start`
2. **Click "Notebooks"** in left menu
3. **Click "CONNECT"** on my-notebook
4. **Start coding** in Jupyter!

Then explore:
- Create new notebooks with different images
- Manage storage volumes
- Deploy more complex ML workloads
- Customize notebook resources

---

## 📚 Resources

- [Kubeflow Documentation](https://www.kubeflow.org/docs/)
- [Jupyter Notebook Images](https://github.com/kubeflow/kubeflow/tree/master/components/example-notebook-servers)
- [Kind Documentation](https://kind.sigs.k8s.io/)
- [Kubectl Cheatsheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

---

## 💡 Tips

- **Use `make status`** frequently to check health
- **Keep Docker Desktop running** at all times
- **Allocate enough memory** (10-12GB) for stability
- **Use `make clean`** if things get stuck
- **Check logs** with kubectl for debugging
- **Backup notebooks** before running `make clean`

---

## ✅ Installation Complete!

You now have a fully functional Kubeflow Notebooks environment running locally! 🎉
