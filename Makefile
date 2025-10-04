.PHONY: help prerequisites cluster clean install start stop status info fast-jupyter fast-start

# Variables
CLUSTER_NAME = kubeflow-local
KUBEFLOW_PORT = 8081
JUPYTER_PORT = 8888

# Default target
.DEFAULT_GOAL = help

help:
	@echo "╔════════════════════════════════════════════════════════════════╗"
	@echo "║                                                                ║"
	@echo "║         Kubeflow Notebooks - Local Setup                      ║"
	@echo "║                                                                ║"
	@echo "╚════════════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "🎯 KUBEFLOW INSTALLATION (Full Features):"
	@echo "  make install          - Complete Kubeflow installation (10-15 min)"
	@echo "  make start            - Access Kubeflow UI at http://localhost:8081"
	@echo "  make stop             - Stop port-forward"
	@echo "  make status           - Check cluster status"
	@echo "  make info             - Show access information"
	@echo ""
	@echo "⚡ FAST JUPYTER (Lightweight Alternative):"
	@echo "  make fast-jupyter     - Deploy standalone Jupyter (~60 seconds)"
	@echo "  make fast-start       - Access at http://localhost:8888"
	@echo ""
	@echo "🔧 Setup & Management:"
	@echo "  make prerequisites    - Install Docker, kubectl, kind"
	@echo "  make cluster          - Create local Kubernetes cluster"
	@echo "  make clean            - Delete cluster and all resources"
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""
	@echo "💡 RECOMMENDATIONS:"
	@echo "   • For full Kubeflow: Use 'make install' (requires 10-12GB RAM)"
	@echo "   • For quick testing: Use 'make fast-jupyter' (requires 2-4GB RAM)"
	@echo ""

prerequisites:
	@echo "🚀 Installing prerequisites..."
	@./scripts/install-prerequisites.sh

cluster:
	@echo "🎯 Creating Kind cluster..."
	@./scripts/setup-kind-cluster.sh

install:
	@echo "╔════════════════════════════════════════════════════════════════╗"
	@echo "║                                                                ║"
	@echo "║         Installing Kubeflow Notebooks                         ║"
	@echo "║                                                                ║"
	@echo "╚════════════════════════════════════════════════════════════════╝"
	@echo ""
	@./scripts/install-kubeflow.sh

start:
	@echo "🌐 Starting Kubeflow access..."
	@echo ""
	@echo "📊 Checking cluster status..."
	@kubectl get pods -n kubeflow 2>/dev/null | grep centraldashboard || (echo "❌ Kubeflow not installed! Run 'make install' first" && exit 1)
	@echo ""
	@echo "🔧 Cleaning up any existing port-forwards..."
	@pkill -9 -f "port-forward.*istio-ingressgateway.*$(KUBEFLOW_PORT)" 2>/dev/null || true
	@sleep 2
	@echo ""
	@echo "🔗 Setting up port-forward..."
	@echo ""
	@echo "📍 Access URL: http://localhost:$(KUBEFLOW_PORT)"
	@echo "🔐 Auto-login as: user@example.com"
	@echo ""
	@echo "⚠️  Press Ctrl+C to stop (port will auto-cleanup)"
	@echo ""
	@sleep 2
	@if command -v open >/dev/null 2>&1; then \
		echo "🚀 Opening browser..."; \
		open http://localhost:$(KUBEFLOW_PORT) 2>/dev/null || true; \
	fi
	@sleep 1
	@trap 'echo ""; echo "🛑 Stopping port-forward..."; pkill -9 -f "port-forward.*istio-ingressgateway.*$(KUBEFLOW_PORT)"; echo "✅ Port cleaned up!"; exit 0' INT TERM; \
	kubectl port-forward -n istio-system svc/istio-ingressgateway $(KUBEFLOW_PORT):80

stop:
	@echo "🛑 Stopping port-forward..."
	@pkill -9 -f "port-forward.*istio-ingressgateway" 2>/dev/null && echo "✅ Port-forward stopped" || echo "No port-forward running"
	@pkill -9 -f "port-forward.*jupyter" 2>/dev/null || true

info:
	@echo "╔════════════════════════════════════════════════════════════════╗"
	@echo "║                                                                ║"
	@echo "║         Kubeflow Access Information                           ║"
	@echo "║                                                                ║"
	@echo "╚════════════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "🌐 Access Kubeflow:"
	@echo "   1. Start port-forward: make start"
	@echo "   2. Open browser: http://localhost:$(KUBEFLOW_PORT)"
	@echo "   3. Click 'Notebooks' in left menu"
	@echo "   4. Click 'CONNECT' on your notebook"
	@echo ""
	@echo "🔐 Authentication:"
	@echo "   • No login required (auto-logged as user@example.com)"
	@echo ""
	@echo "📊 Current Status:"
	@kubectl get deployments -n kubeflow 2>/dev/null | head -5 || echo "   ❌ Kubeflow not installed"
	@echo ""
	@kubectl get notebooks,pods -n kubeflow-user-example-com 2>/dev/null || echo "   ❌ No notebooks deployed"
	@echo ""

fast-jupyter:
	@echo "⚡ DEPLOYING FAST JUPYTER (NO KUBEFLOW NEEDED)"
	@echo ""
	@echo "🚀 This deploys a lightweight Jupyter in 30-60 seconds!"
	@echo ""
	@echo "1️⃣  Creating namespace and deploying..."
	@kubectl apply -f examples/fast-jupyter.yaml
	@echo ""
	@echo "2️⃣  Waiting for pod to be ready..."
	@sleep 5
	@kubectl wait --for=condition=ready --timeout=120s pod -l app=jupyter -n jupyter 2>&1 | grep -v "error:" || echo "  Still starting..."
	@echo ""
	@echo "3️⃣  Getting pod status..."
	@kubectl get pods -n jupyter
	@echo ""
	@echo "✅ JUPYTER IS READY!"
	@echo ""
	@echo "📍 Access:"
	@echo "   make fast-start"
	@echo "   Then open: http://localhost:8888"
	@echo ""
	@echo "🔐 Password: jupyter123"
	@echo ""

fast-start:
	@echo "🌐 Starting Jupyter access..."
	@echo ""
	@echo "📊 Checking Jupyter status..."
	@kubectl get pods -n jupyter 2>/dev/null || (echo "❌ Jupyter not deployed! Run 'make fast-jupyter' first" && exit 1)
	@echo ""
	@echo "🔧 Cleaning up any existing port-forwards..."
	@pkill -9 -f "port-forward.*jupyter.*8888" 2>/dev/null || true
	@sleep 2
	@echo ""
	@echo "🔗 Setting up port-forward..."
	@echo ""
	@echo "📍 Access URL: http://localhost:8888"
	@echo "🔐 Password: jupyter123"
	@echo ""
	@echo "⚠️  Press Ctrl+C to stop (port will auto-cleanup)"
	@echo ""
	@sleep 2
	@if command -v open >/dev/null 2>&1; then \
		echo "🚀 Opening browser..."; \
		open http://localhost:8888 2>/dev/null || true; \
	fi
	@sleep 1
	@trap 'echo ""; echo "🛑 Stopping port-forward..."; pkill -9 -f "port-forward.*jupyter.*8888"; echo "✅ Port cleaned up!"; exit 0' INT TERM; \
	kubectl port-forward -n jupyter svc/jupyter 8888:8888

status:
	@echo "╔════════════════════════════════════════════════════════════════╗"
	@echo "║                                                                ║"
	@echo "║         Deployment Status                                     ║"
	@echo "║                                                                ║"
	@echo "╚════════════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "🎯 Cluster:"
	@kind get clusters 2>/dev/null | grep -q "$(CLUSTER_NAME)" && echo "  ✅ Cluster '$(CLUSTER_NAME)' running" || echo "  ❌ Cluster not found"
	@echo ""
	@echo "📊 Kubeflow (Full Installation):"
	@kubectl get deployments -n kubeflow 2>/dev/null | head -5 || echo "  ❌ Not installed"
	@echo ""
	@kubectl get pods -n kubeflow-user-example-com 2>/dev/null || echo "  ❌ No user namespace found"
	@echo ""
	@echo "⚡ Fast Jupyter (Lightweight):"
	@kubectl get pods -n jupyter 2>/dev/null || echo "  ❌ Not deployed"
	@echo ""
	@echo "🔗 Port-forwards:"
	@ps aux | grep "port-forward.*istio-ingressgateway" | grep -v grep | awk '{print "  ✅ Kubeflow UI on port $(KUBEFLOW_PORT) (PID " $$2 ")"}' || echo "  → Kubeflow: Not running (use 'make start')"
	@ps aux | grep "port-forward.*jupyter.*8888" | grep -v grep | awk '{print "  ✅ Fast Jupyter on port 8888 (PID " $$2 ")"}' || echo "  → Fast Jupyter: Not running (use 'make fast-start')"
	@echo ""

clean:
	@echo "🗑️  Cleaning up..."
	@./scripts/cleanup.sh
	@echo ""
	@echo "✅ All resources deleted!"
	@echo ""
	@echo "To start again:"
	@echo "  make cluster"
	@echo "  make fast-jupyter"
	@echo "  make fast-start"