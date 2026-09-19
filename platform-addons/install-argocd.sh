#!/usr/bin/env bash
set -euo pipefail

readonly ARGOCD_CHART_VERSION="${ARGOCD_CHART_VERSION:-10.9.2}"
readonly ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"

SCRIPT_DIR="$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
  pwd
)"

helm repo add argo https://argoproj.github.io/argo-helm --force-update
helm repo update argo

helm upgrade --install argocd argo/argo-cd \
  --version "$ARGOCD_CHART_VERSION" \
  --namespace "$ARGOCD_NAMESPACE" \
  --create-namespace \
  --values "${SCRIPT_DIR}/argocd-values.yaml" \
  --wait \
  --timeout 10m

kubectl get pods \
  --namespace "$ARGOCD_NAMESPACE"
