# terraform-aws-eks-platform

Production-grade EKS platform provisioned with Terraform, with Helm-deployed workloads and a CloudFormation-driven CI/CD pipeline.

## Architecture

```
AWS (ca-west-1)
├── VPC  (2 public + 2 private subnets, NAT Gateway)
├── EKS Cluster  (v1.29, managed node group)
│   ├── Helm release: nginx-app   (Nginx web server)
│   └── Helm release: flask-app   (Python Flask microservice)
├── IAM  (OIDC provider, node role, pod execution role)
├── CloudWatch  (Container Insights, cluster alarms)
└── CI/CD  (CloudFormation → CodePipeline + CodeBuild)
```

## Skills Demonstrated

| Skill | Where |
|---|---|
| Terraform IaC | `terraform/` modules + staging env |
| EKS / Kubernetes | `terraform/modules/eks`, Helm deploys |
| VPC design | `terraform/modules/vpc` |
| IAM / least-privilege | `terraform/modules/iam` |
| CloudWatch observability | `terraform/modules/cloudwatch` |
| Helm chart authoring | `helm/nginx-app`, `helm/flask-app` |
| Python microservice | `app/` |
| AWS CodePipeline CI/CD | `cicd/pipeline.yaml` |

## Quick Start

### Prerequisites
- AWS CLI configured (`aws configure`)
- Terraform >= 1.6
- kubectl
- helm >= 3.x

### 1 – Deploy Infrastructure

```bash
cd terraform/envs/staging
terraform init
terraform plan
terraform apply
```

### 2 – Configure kubectl

```bash
aws eks update-kubeconfig \
  --region ca-west-1 \
  --name $(terraform output -raw cluster_name)
```

### 3 – Deploy workloads via Helm

```bash
# Nginx
helm upgrade --install nginx-app ./helm/nginx-app \
  --namespace default --create-namespace

# Flask microservice
helm upgrade --install flask-app ./helm/flask-app \
  --namespace default
```

### 4 – Deploy CI/CD Pipeline

```bash
aws cloudformation deploy \
  --template-file cicd/pipeline.yaml \
  --stack-name eks-platform-pipeline \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides GitHubOwner=<YOUR_GITHUB_USER> \
                        GitHubRepo=terraform-aws-eks-platform \
                        GitHubBranch=main
```

## Cost-Free Testing Options

See [FREE_TIER_TESTING.md](FREE_TIER_TESTING.md) for how to test everything locally (kind, LocalStack, minikube) before touching AWS.

## Module Reference

| Module | Description |
|---|---|
| `vpc` | VPC, subnets, IGW, NAT, route tables |
| `eks` | EKS control plane + managed node group |
| `iam` | OIDC, node role, pod role, policies |
| `cloudwatch` | Log groups, Container Insights, CPU/memory alarms |
