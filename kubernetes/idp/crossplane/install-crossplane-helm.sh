#!/bin/bash

# Crossplane Installation using Helm
# This script installs Crossplane using the official Helm chart

set -e

echo "🚀 Installing Crossplane using Helm..."

# Add Crossplane Helm repository
echo "📦 Adding Crossplane Helm repository..."
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update

# Install Crossplane using Helm
echo "🔧 Installing Crossplane..."
helm upgrade --install crossplane crossplane-stable/crossplane \
  --namespace crossplane-system \
  --create-namespace \
  --version 1.16.0 \
  --wait \
  --timeout 10m

echo "⏳ Waiting for Crossplane to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/crossplane -n crossplane-system

echo "✅ Crossplane installation completed successfully!"
echo ""
echo "🔍 To verify the installation, run:"
echo "   kubectl get pods -n crossplane-system"
echo "   kubectl get crd | grep crossplane"
echo ""
echo "📚 Next steps:"
echo "   1. Install a provider (e.g., AWS, GCP, Azure)"
echo "   2. Create a Configuration to install packages"
echo "   3. Create Composite Resources (XRs) and Definitions (XRDs)"
