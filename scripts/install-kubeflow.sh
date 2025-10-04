#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
KUBEFLOW_VERSION="v1.9.0"
ISTIO_VERSION="1.22.0"
CERT_MANAGER_VERSION="v1.12.0"

echo -e "${BLUE}"
cat << "EOF"
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║         KUBEFLOW NOTEBOOKS - END-TO-END INSTALLATION           ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${GREEN}📦 Starting Kubeflow installation...${NC}"
echo ""

# Step 1: Check prerequisites
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}1️⃣  Checking prerequisites...${NC}"
echo ""

if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker not found. Please install Docker Desktop.${NC}"
    exit 1
fi
echo "   ✅ Docker installed"

if ! docker info &> /dev/null; then
    echo -e "${RED}❌ Docker daemon is not running. Please start Docker Desktop.${NC}"
    exit 1
fi
echo "   ✅ Docker daemon running"

# Check Docker memory
DOCKER_MEM=$(docker info --format '{{.MemTotal}}' 2>/dev/null)
DOCKER_MEM_GB=$((DOCKER_MEM / 1024 / 1024 / 1024))
if [ "$DOCKER_MEM_GB" -lt 8 ]; then
    echo -e "${YELLOW}⚠️  Warning: Docker has ${DOCKER_MEM_GB}GB RAM. Recommended: 10-12GB${NC}"
    echo "   Increase in Docker Desktop → Settings → Resources → Memory"
fi
echo "   ✅ Docker memory: ${DOCKER_MEM_GB}GB"

if ! command -v kubectl &> /dev/null; then
    echo -e "${YELLOW}⚠️  kubectl not found. Installing...${NC}"
    ./scripts/install-prerequisites.sh
fi
echo "   ✅ kubectl installed"

if ! command -v kind &> /dev/null; then
    echo -e "${YELLOW}⚠️  kind not found. Installing...${NC}"
    ./scripts/install-prerequisites.sh
fi
echo "   ✅ kind installed"

if ! command -v kustomize &> /dev/null; then
    echo -e "${YELLOW}⚠️  kustomize not found. Installing...${NC}"
    ./scripts/install-prerequisites.sh
fi
echo "   ✅ kustomize installed"

echo ""

# Step 2: Create Kind cluster
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}2️⃣  Creating Kind cluster...${NC}"
echo ""

if kind get clusters 2>/dev/null | grep -q "kubeflow-local"; then
    echo "   ⚠️  Cluster 'kubeflow-local' already exists"
    echo "   → Using existing cluster"
    echo "   💡 To start fresh, run: make clean && make install"
else
    ./scripts/setup-kind-cluster.sh
fi

echo "   ✅ Kind cluster ready"
echo ""

# Step 3: Download Kubeflow manifests
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}3️⃣  Downloading Kubeflow manifests...${NC}"
echo ""

# Create temporary directory for manifests
MANIFESTS_DIR=$(mktemp -d)
echo "   📦 Cloning Kubeflow manifests repository (version ${KUBEFLOW_VERSION})..."
git clone --depth 1 --branch ${KUBEFLOW_VERSION} https://github.com/kubeflow/manifests.git $MANIFESTS_DIR/kubeflow-manifests 2>&1 | head -5
echo "   ✅ Manifests downloaded to temporary directory"
echo ""

# Step 4: Install cert-manager
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}4️⃣  Installing cert-manager...${NC}"
echo ""

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/${CERT_MANAGER_VERSION}/cert-manager.yaml
echo "   ⏳ Waiting for cert-manager to be ready..."
kubectl wait --for=condition=available --timeout=180s deployment/cert-manager -n cert-manager 2>&1 | grep -v "error:" || true
kubectl wait --for=condition=available --timeout=180s deployment/cert-manager-webhook -n cert-manager 2>&1 | grep -v "error:" || true
echo "   ✅ cert-manager installed"
echo ""

# Step 5: Install Istio
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}5️⃣  Installing Istio ${ISTIO_VERSION}...${NC}"
echo ""

echo "   📦 Installing Istio CRDs..."
kubectl apply -k $MANIFESTS_DIR/kubeflow-manifests/common/istio-1-22/istio-crds/base

echo "   📦 Installing Istio namespace..."
kubectl apply -k $MANIFESTS_DIR/kubeflow-manifests/common/istio-1-22/istio-namespace/base

echo "   📦 Installing Istio..."
kubectl apply -k $MANIFESTS_DIR/kubeflow-manifests/common/istio-1-22/istio-install/base

echo "   ⏳ Waiting for Istio to be ready..."
kubectl wait --for=condition=available --timeout=180s deployment/istiod -n istio-system 2>&1 | grep -v "error:" || true
kubectl wait --for=condition=available --timeout=180s deployment/istio-ingressgateway -n istio-system 2>&1 | grep -v "error:" || true
echo "   ✅ Istio installed"
echo ""

# Step 6: Skip Dex and OAuth2 Proxy (Using direct login)
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}6️⃣  Skipping authentication services (direct login enabled)...${NC}"
echo ""

# Dex and OAuth2 Proxy installation skipped for direct access
echo "   ⏭️  Dex installation skipped"
echo "   ⏭️  OAuth2 Proxy installation skipped"
echo "   ✅ Direct login will be configured"
echo ""

# Step 7: Install Kubeflow core components
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}7️⃣  Installing Kubeflow core components...${NC}"
echo ""

echo "   📦 Installing Kubeflow namespace..."
kubectl apply -k $MANIFESTS_DIR/kubeflow-manifests/common/kubeflow-namespace/base

echo "   📦 Installing Kubeflow roles..."
kubectl apply -k $MANIFESTS_DIR/kubeflow-manifests/common/kubeflow-roles/base

echo "   📦 Installing Kubeflow Istio resources..."
kubectl apply -k $MANIFESTS_DIR/kubeflow-manifests/common/istio-1-22/kubeflow-istio-resources/base

echo "   ✅ Core components installed"
echo ""

# Step 8: Install Central Dashboard
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}8️⃣  Installing Central Dashboard...${NC}"
echo ""

kubectl apply -k $MANIFESTS_DIR/kubeflow-manifests/apps/centraldashboard/upstream/overlays/istio

echo "   ⏳ Waiting for dashboard..."
kubectl wait --for=condition=available --timeout=180s deployment/centraldashboard -n kubeflow 2>&1 | grep -v "error:" || true
echo "   ✅ Central Dashboard installed"
echo ""

# Step 9: Install Profile Controller
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}9️⃣  Installing Profile Controller...${NC}"
echo ""

kubectl apply -k $MANIFESTS_DIR/kubeflow-manifests/apps/profiles/upstream/overlays/kubeflow

echo "   ⏳ Waiting for profiles-deployment..."
kubectl wait --for=condition=available --timeout=180s deployment/profiles-deployment -n kubeflow 2>&1 | grep -v "error:" || true
echo "   ✅ Profile Controller installed"
echo ""

# Step 10: Install Notebook Components
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🔟 Installing Notebook components...${NC}"
echo ""

echo "   📦 Installing Jupyter Web App..."
kubectl apply -k $MANIFESTS_DIR/kubeflow-manifests/apps/jupyter/jupyter-web-app/upstream/overlays/istio

echo "   📦 Installing Notebook Controller..."
kubectl apply -k $MANIFESTS_DIR/kubeflow-manifests/apps/jupyter/notebook-controller/upstream/overlays/kubeflow

echo "   📦 Installing Volumes Web App..."
kubectl apply -k $MANIFESTS_DIR/kubeflow-manifests/apps/volumes-web-app/upstream/overlays/istio

echo "   ⏳ Waiting for notebook components..."
kubectl wait --for=condition=available --timeout=180s deployment/jupyter-web-app-deployment -n kubeflow 2>&1 | grep -v "error:" || true
kubectl wait --for=condition=available --timeout=180s deployment/notebook-controller-deployment -n kubeflow 2>&1 | grep -v "error:" || true
kubectl wait --for=condition=available --timeout=180s deployment/volumes-web-app-deployment -n kubeflow 2>&1 | grep -v "error:" || true
echo "   ✅ Notebook components installed"
echo ""

# Step 11: Configure authentication for local dev
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}⚙️  Configuring authentication for local development...${NC}"
echo ""

# Remove JWT validation
echo "   🔧 Removing JWT validation..."
kubectl delete requestauthentication dex-jwt -n istio-system 2>/dev/null || true
kubectl delete requestauthentication m2m-token-issuer -n istio-system 2>/dev/null || true

# Remove restrictive authorization policies
echo "   🔧 Opening authorization policies..."
kubectl delete authorizationpolicy global-deny-all -n istio-system 2>/dev/null || true
kubectl delete authorizationpolicy istio-ingressgateway-require-jwt -n istio-system 2>/dev/null || true
kubectl delete authorizationpolicy istio-ingressgateway-oauth2-proxy -n istio-system 2>/dev/null || true

# Create allow-all policy
kubectl apply -f - << 'YAML'
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: allow-all-ingress
  namespace: istio-system
spec:
  selector:
    matchLabels:
      app: istio-ingressgateway
  action: ALLOW
  rules:
  - {}
YAML

# Configure centraldashboard to accept user headers
echo "   🔧 Configuring centraldashboard..."
kubectl apply -f - << 'YAML'
apiVersion: v1
kind: ConfigMap
metadata:
  name: centraldashboard-config
  namespace: kubeflow
data:
  CD_CLUSTER_DOMAIN: cluster.local
  CD_USERID_HEADER: kubeflow-userid
  CD_USERID_PREFIX: ""
  CD_REGISTRATION_FLOW: "false"
  links: |-
    {
      "menuLinks": [
        {
          "type": "item",
          "link": "/jupyter/",
          "text": "Notebooks",
          "icon": "book"
        },
        {
          "type": "item",
          "link": "/volumes/",
          "text": "Volumes",
          "icon": "device:storage"
        }
      ],
      "externalLinks": [],
      "quickLinks": [
        {
          "text": "Jupyter Notebooks",
          "desc": "Create and manage Jupyter notebook servers",
          "link": "/jupyter/"
        }
      ],
      "documentationItems": []
    }
YAML

kubectl set env deployment/centraldashboard -n kubeflow \
  CD_USERID_HEADER=kubeflow-userid \
  CD_USERID_PREFIX="" \
  CD_REGISTRATION_FLOW=false 2>&1 | grep -v "Warning" || true

# Create EnvoyFilter to inject user header
kubectl apply -f - << 'YAML'
apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: authn-filter
  namespace: istio-system
spec:
  workloadSelector:
    labels:
      app: istio-ingressgateway
  configPatches:
  - applyTo: HTTP_FILTER
    match:
      context: GATEWAY
      listener:
        filterChain:
          filter:
            name: "envoy.filters.network.http_connection_manager"
    patch:
      operation: INSERT_BEFORE
      value:
        name: envoy.lua
        typed_config:
          "@type": "type.googleapis.com/envoy.extensions.filters.http.lua.v3.Lua"
          inline_code: |
            function envoy_on_request(request_handle)
              request_handle:headers():add("kubeflow-userid", "user@example.com")
            end
YAML

# Grant permissive RBAC
kubectl create clusterrolebinding kubeflow-admin-binding \
  --clusterrole=cluster-admin \
  --serviceaccount=kubeflow-user-example-com:default-editor 2>/dev/null || true

kubectl create clusterrolebinding authenticated-edit \
  --clusterrole=edit \
  --group=system:authenticated 2>/dev/null || true

echo "   ⏳ Restarting services..."
kubectl rollout restart deployment/centraldashboard -n kubeflow
kubectl rollout restart deployment/istio-ingressgateway -n istio-system
kubectl wait --for=condition=available --timeout=60s deployment/centraldashboard -n kubeflow 2>&1 | grep -v "error:" || true
kubectl wait --for=condition=available --timeout=60s deployment/istio-ingressgateway -n istio-system 2>&1 | grep -v "error:" || true

echo "   ✅ Authentication configured"
echo ""

# Step 12: Create user profile
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}👤 Creating user profile...${NC}"
echo ""

kubectl apply -f - << 'YAML'
apiVersion: kubeflow.org/v1
kind: Profile
metadata:
  name: kubeflow-user-example-com
spec:
  owner:
    kind: User
    name: user@example.com
  resourceQuotaSpec: {}
YAML

echo "   ⏳ Waiting for namespace creation..."
for i in {1..30}; do
  STATUS=$(kubectl get namespace kubeflow-user-example-com -o jsonpath='{.status.phase}' 2>/dev/null)
  if [ "$STATUS" == "Active" ]; then
    echo "   ✅ User namespace created"
    break
  fi
  sleep 2
done

# Add RBAC for user
kubectl create rolebinding user-admin \
  --clusterrole=admin \
  --user=user@example.com \
  --namespace=kubeflow-user-example-com 2>/dev/null || echo "   → RBAC already exists"

echo "   ✅ User profile ready"
echo ""

# Step 13: Deploy sample notebook
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}📔 Deploying sample notebook...${NC}"
echo ""

kubectl apply -f examples/kubeflow-notebook.yaml

echo "   ⏳ Waiting for notebook pod..."
for i in {1..24}; do
  STATUS=$(kubectl get pods -n kubeflow-user-example-com -l app=my-notebook 2>/dev/null | tail -1 | awk '{print $3}')
  READY=$(kubectl get pods -n kubeflow-user-example-com -l app=my-notebook 2>/dev/null | tail -1 | awk '{print $2}')
  
  if [ "$READY" == "2/2" ]; then
    echo "   ✅ Notebook is ready!"
    break
  else
    echo "   [$i/24] Status: $STATUS | Ready: $READY"
  fi
  sleep 5
done

echo ""

# Cleanup
echo "   🗑️  Cleaning up temporary files..."
rm -rf $MANIFESTS_DIR
echo ""

# Final verification
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ INSTALLATION COMPLETE!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${GREEN}📊 Final Status:${NC}"
echo ""
kubectl get deployments -n kubeflow | head -6
echo ""
kubectl get pods -n kubeflow-user-example-com
echo ""

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}🎯 ACCESS YOUR KUBEFLOW INSTALLATION:${NC}"
echo ""
echo -e "${YELLOW}1. Start port-forward:${NC}"
echo "   make start"
echo "   (or manually: kubectl port-forward svc/istio-ingressgateway -n istio-system 8081:80)"
echo ""
echo -e "${YELLOW}2. Open browser:${NC}"
echo "   http://localhost:8081"
echo ""
echo -e "${YELLOW}3. Access your notebook:${NC}"
echo "   • Click 'Notebooks' in the left menu"
echo "   • Find 'my-notebook'"
echo "   • Click 'CONNECT'"
echo ""
echo -e "${GREEN}🔐 Authentication:${NC}"
echo "   • No login required (bypassed for local dev)"
echo "   • Auto-logged in as: user@example.com"
echo ""
echo -e "${GREEN}📝 Useful Commands:${NC}"
echo "   make start    - Start port-forward to access UI"
echo "   make stop     - Stop port-forward"
echo "   make status   - Check cluster status"
echo "   make info     - Show access information"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}✅ Kubeflow Notebooks is ready to use!${NC}"
echo ""
