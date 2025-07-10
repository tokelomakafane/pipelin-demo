#!/bin/bash

# DigitalOcean Kubernetes Deployment Script
# This script helps deploy the Thuto application to DigitalOcean Kubernetes

set -e

echo "🌊 DigitalOcean Kubernetes Deployment Script"
echo "============================================"

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Check if doctl is installed (optional but recommended)
if ! command -v doctl &> /dev/null; then
    echo "⚠️  doctl is not installed. Install it for easier DigitalOcean management."
    echo "   Visit: https://docs.digitalocean.com/reference/doctl/how-to/install/"
fi

# Function to check if user wants to continue
confirm() {
    read -p "$1 (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Operation cancelled."
        exit 1
    fi
}

# Check if kubeconfig is set
if [ -z "$KUBECONFIG" ]; then
    echo "📝 Please set your KUBECONFIG environment variable:"
    echo "   export KUBECONFIG=/path/to/your/kubeconfig"
    echo ""
    echo "   You can download the kubeconfig from DigitalOcean dashboard:"
    echo "   Kubernetes → Your Cluster → Actions → Download Config File"
    exit 1
fi

# Test kubectl connection
echo "🔍 Testing kubectl connection..."
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster. Check your kubeconfig."
    exit 1
fi

echo "✅ Connected to Kubernetes cluster"

# Show cluster info
echo "📊 Cluster Information:"
kubectl cluster-info
echo ""

# Ask for confirmation before deployment
echo "🚀 This will deploy the Thuto application to your DigitalOcean Kubernetes cluster."
confirm "Do you want to continue?"

# Create namespace
echo "📁 Creating namespace..."
kubectl apply -f k8s/namespace.yaml

# Apply secrets (user should update these first)
echo "🔐 Applying secrets..."
echo "⚠️  Make sure you've updated k8s/secrets.yaml with your production values!"
confirm "Have you updated the secrets in k8s/secrets.yaml?"
kubectl apply -f k8s/secrets.yaml

# Apply configmap
echo "⚙️  Applying configuration..."
kubectl apply -f k8s/configmap.yaml

# Apply deployment
echo "🚀 Deploying application..."
kubectl apply -f k8s/deployment.yaml

# Apply service
echo "🌐 Creating service..."
kubectl apply -f k8s/service.yaml

# Apply HPA
echo "📈 Setting up auto-scaling..."
kubectl apply -f k8s/hpa.yaml

# Apply ingress (optional)
echo "🌍 Setting up ingress..."
echo "⚠️  Make sure you've updated the domain in k8s/ingress.yaml!"
read -p "Do you want to apply the ingress? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    kubectl apply -f k8s/ingress.yaml
fi

# Wait for deployment
echo "⏳ Waiting for deployment to be ready..."
kubectl rollout status deployment/thuto-app -n thuto --timeout=300s

# Show deployment status
echo ""
echo "🎉 Deployment complete!"
echo ""
echo "📊 Deployment Status:"
kubectl get pods -n thuto
echo ""
kubectl get services -n thuto
echo ""
kubectl get hpa -n thuto

# Show ingress if applied
if kubectl get ingress -n thuto &> /dev/null; then
    echo ""
    kubectl get ingress -n thuto
fi

echo ""
echo "🔗 To access your application:"
if kubectl get ingress -n thuto &> /dev/null; then
    echo "   External URL: Check the ingress address above"
else
    echo "   Port forward: kubectl port-forward service/thuto-service -n thuto 8080:80"
    echo "   Then visit: http://localhost:8080"
fi

echo ""
echo "📝 Useful commands:"
echo "   View logs: kubectl logs -n thuto deployment/thuto-app"
echo "   Scale: kubectl scale deployment/thuto-app -n thuto --replicas=5"
echo "   Delete: kubectl delete -f k8s/"

echo ""
echo "✅ Deployment script completed successfully!"
