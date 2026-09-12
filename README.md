# HistData Kubernetes deployments

Deployment configuration is kept separate from application source and
Terraform. This repository contains both raw manifests for learning and a Helm
chart for repeatable environment deployments.

## Repository layout

```text
raw/                    # readable baseline Kubernetes objects
charts/histdata/        # reusable Helm chart
environments/dev/       # environment-specific Helm values
platform-addons/        # controller bootstrap notes/scripts
.github/workflows/      # validation and controlled deployment
```

Do not apply both `raw/` and Helm for the same release. Start with raw manifests
to learn the objects, delete that release, then use Helm.

## Prerequisites

- EKS cluster and Terraform outputs
- AWS Load Balancer Controller
- External Secrets Operator
- An application image in ECR
- Application IRSA role
- An Oracle application schema/secret
- ACM certificate and DNS hostname for HTTPS

## Install platform add-ons

Set values returned by Terraform and run:

```bash
export CLUSTER_NAME=histdata-dev-eks
export AWS_REGION=ap-south-1
export VPC_ID=vpc-xxxxxxxx
export ALB_CONTROLLER_ROLE_ARN=arn:aws:iam::123456789012:role/...
export EXTERNAL_SECRETS_ROLE_ARN=arn:aws:iam::123456789012:role/...
./platform-addons/install.sh
```

## Deploy with Helm

Edit `environments/dev/values.yaml`, then:

```bash
helm lint charts/histdata -f environments/dev/values.yaml
helm upgrade --install histdata charts/histdata \
  --namespace histdata --create-namespace \
  -f environments/dev/values.yaml
```

## Database secret

The chart uses External Secrets to create `histdata-db` from AWS Secrets
Manager. Use Terraform's `oracle_application_secret_arn` output after creating
the dedicated, least-privileged Oracle `HISTDATA` schema user. Do not use the
RDS master account for the application.

## DNS

After the ALB appears, point the selected hostname to the ALB. If Route 53 is
used, prefer an Alias A/AAAA record. For an external DNS provider, use the
provider-supported CNAME/ALIAS mechanism.
