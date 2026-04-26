# Free-Tier & Zero-Cost Testing Guide

You asked: *"How do I test this without cost or paid resources?"*
Here are three strategies, from easiest to most complete.

---

## Strategy 1 – Local Kubernetes with `kind` (Recommended First Step)

`kind` (Kubernetes IN Docker) runs a real Kubernetes cluster inside Docker on your laptop. Free, instant, no AWS account needed.

### Install

```bash
# macOS
brew install kind

# Linux
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-amd64
chmod +x ./kind && sudo mv ./kind /usr/local/bin/kind
```

### Create a cluster and deploy Helm charts

```bash
# Start a local cluster
kind create cluster --name eks-local

# Deploy nginx-app
helm upgrade --install nginx-app ./helm/nginx-app --create-namespace -n default

# Deploy flask-app
helm upgrade --install flask-app ./helm/flask-app -n default

# Check pods
kubectl get pods

# Access flask-app locally
kubectl port-forward svc/flask-app 8080:80
curl http://localhost:8080/health
```

### What this tests
- All Helm chart syntax
- Kubernetes manifests (Deployments, Services, ConfigMaps)
- Pod startup and health checks
- Inter-service communication

---

## Strategy 2 – Terraform with LocalStack (AWS API Mock)

LocalStack emulates AWS services (S3, IAM, EC2, CloudWatch, etc.) locally. Free community edition is enough for this project.

### Install

```bash
pip install localstack
pip install terraform-local   # tflocal wrapper

# Start LocalStack
localstack start -d
```

### Run Terraform against LocalStack

```bash
cd terraform/envs/staging

# Use tflocal instead of terraform – it redirects all API calls to localhost
tflocal init
tflocal plan
tflocal apply
```

### What this tests
- Terraform module syntax and dependency graph
- VPC, IAM, CloudWatch resource definitions
- Variable passing between modules
- Output values

**Note:** EKS is not fully supported in LocalStack Free. Use it to validate VPC + IAM + CloudWatch modules.

---

## Strategy 3 – AWS Free Tier (Minimal Real Cost)

If you want to test EKS itself, use the Free Tier carefully:

| Resource | Free Tier | Notes |
|---|---|---|
| EKS Control Plane | **NOT free** – $0.10/hr | ~$2.40/day; destroy after testing |
| EC2 t3.micro nodes | 750 hrs/month free (first year) | Use `t3.micro` node group |
| VPC / Subnets | Free | |
| IAM | Free | |
| CloudWatch basic | Free | 5GB logs, 10 metrics |
| NAT Gateway | ~$0.045/hr | Use single NAT in staging config |

### Estimated cost for a 2-hour test session
- EKS control plane: ~$0.20
- NAT Gateway: ~$0.09
- **Total: ~$0.30 for a full end-to-end test**

### Always destroy after testing!

```bash
# Remove Helm releases first (avoids stuck LoadBalancer resources)
helm uninstall nginx-app
helm uninstall flask-app

# Then destroy infrastructure
cd terraform/envs/staging
terraform destroy -auto-approve
```

### Set a billing alarm to protect yourself

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name billing-alert-5usd \
  --metric-name EstimatedCharges \
  --namespace AWS/Billing \
  --statistic Maximum \
  --period 86400 \
  --threshold 5 \
  --comparison-operator GreaterThanThreshold \
  --dimensions Name=Currency,Value=USD \
  --evaluation-periods 1 \
  --alarm-actions arn:aws:sns:us-east-1:<ACCOUNT_ID>:<SNS_TOPIC>
```

---

## Strategy 4 – GitHub Actions Dry-Run (No AWS Needed)

Push to a branch and let the pipeline run `terraform plan` only (no apply). The `cicd/pipeline.yaml` supports a `PLAN_ONLY=true` parameter for this.

---

## Recommended Learning Path

```
Week 1:  kind + Helm charts  →  master Kubernetes locally
Week 2:  LocalStack + Terraform  →  validate all IaC modules
Week 3:  30-min AWS free tier session  →  real EKS end-to-end
Week 4:  CI/CD pipeline  →  push to GitHub, watch CodePipeline run
```
