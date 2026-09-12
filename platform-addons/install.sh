#!/usr/bin/env bash
set -euo pipefail

: "${CLUSTER_NAME:?Set CLUSTER_NAME}"
: "${AWS_REGION:?Set AWS_REGION}"
: "${VPC_ID:?Set VPC_ID}"
: "${ALB_CONTROLLER_ROLE_ARN:?Set ALB_CONTROLLER_ROLE_ARN}"
: "${EXTERNAL_SECRETS_ROLE_ARN:?Set EXTERNAL_SECRETS_ROLE_ARN}"

aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "$AWS_REGION"

helm repo add eks https://aws.github.io/eks-charts
helm repo add external-secrets https://charts.external-secrets.io
helm repo update

kubectl create namespace external-secrets --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  --namespace kube-system \
  --set clusterName="$CLUSTER_NAME" \
  --set region="$AWS_REGION" \
  --set vpcId="$VPC_ID" \
  --set serviceAccount.create=true \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set-string serviceAccount.annotations.eks\.amazonaws\.com/role-arn="$ALB_CONTROLLER_ROLE_ARN"

helm upgrade --install external-secrets external-secrets/external-secrets \
  --namespace external-secrets \
  --set installCRDs=true \
  --set serviceAccount.create=true \
  --set serviceAccount.name=external-secrets \
  --set-string serviceAccount.annotations.eks\.amazonaws\.com/role-arn="$EXTERNAL_SECRETS_ROLE_ARN"

kubectl rollout status deployment/aws-load-balancer-controller -n kube-system --timeout=180s
kubectl rollout status deployment/external-secrets -n external-secrets --timeout=180s

