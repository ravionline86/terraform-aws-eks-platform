# GitHub Setup Guide – Step by Step
## For: terraform-aws-eks-platform

This guide walks you through GitHub from scratch to a working repository.

---

## Part 1 – One-Time Setup (do this once)

### Step 1: Create a GitHub account
1. Go to https://github.com/signup
2. Use your email: ravionline86@gmail.com
3. Choose a username – recommendation: `ravinder-kumar-cloud` or your existing handle
4. Verify your email

### Step 2: Install Git on your laptop
```bash
# Check if already installed
git --version

# If not installed:
# macOS:
brew install git

# Ubuntu/Debian Linux:
sudo apt-get install git

# Windows: download from https://git-scm.com/download/win
```

### Step 3: Configure Git with your identity
```bash
git config --global user.name "Ravinder Kumar"
git config --global user.email "ravionline86@gmail.com"
```

### Step 4: Set up SSH authentication (one-time, more secure than password)
```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "ravionline86@gmail.com"
# Press Enter for all prompts (use default location, no passphrase for simplicity)

# Copy the public key to clipboard
cat ~/.ssh/id_ed25519.pub
# Copy the entire output line

# In GitHub:
# → Settings → SSH and GPG keys → New SSH key
# Paste the key, title it "My Laptop", Save
```

---

## Part 2 – Create and Push This Repository

### Step 5: Create a new repository on GitHub
1. Click the **+** button → **New repository**
2. Repository name: `terraform-aws-eks-platform`
3. Description: `Terraform + EKS + Helm + CloudFormation CI/CD – Cloud/SRE Portfolio`
4. Set to **Public** (recruiters and hiring managers can see it)
5. Do NOT check "Add README" (we already have one)
6. Click **Create repository**

### Step 6: Push your local code to GitHub

```bash
# Navigate to the repository folder
cd terraform-aws-eks-platform

# Initialise Git
git init

# Add all files
git add .

# First commit
git commit -m "Initial commit: EKS platform with Terraform, Helm, and CloudFormation CI/CD"

# Connect to GitHub (replace YOUR_USERNAME with your GitHub username)
git remote add origin git@github.com:YOUR_USERNAME/terraform-aws-eks-platform.git

# Push to GitHub
git branch -M main
git push -u origin main
```

### Step 7: Verify it looks right
Go to https://github.com/YOUR_USERNAME/terraform-aws-eks-platform
You should see all your files and the README rendered on the homepage.

---

## Part 3 – GitHub Actions Setup (Free CI/CD)

The three workflows in `.github/workflows/` run automatically on every Push or Pull Request.
They are **completely free** – GitHub gives you 2,000 minutes/month on free accounts.

### What each workflow does (no AWS needed):

| Workflow | Trigger | What runs | Cost |
|---|---|---|---|
| `helm-lint.yml` | PR touching `helm/` | Helm lint + template render | Free |
| `flask-build-test.yml` | PR/push to `app/` | Docker build + endpoint tests | Free |
| `terraform-plan.yml` | PR touching `terraform/` | `terraform validate` + plan | Needs AWS keys |

### For terraform-plan.yml – add AWS credentials as GitHub Secrets:
1. In your repo → **Settings → Secrets and variables → Actions → New repository secret**
2. Add:
   - `AWS_ACCESS_KEY_ID` – your AWS IAM user access key
   - `AWS_SECRET_ACCESS_KEY` – your AWS IAM user secret key

> **Tip:** Create a separate IAM user with limited permissions for CI/CD.
> Do NOT use your root AWS credentials.

---

## Part 4 – CloudFormation CI/CD Pipeline Setup

This is the main `cicd/pipeline.yaml` – it creates a full AWS CodePipeline.

### Prerequisites

#### 4a. Create a CodeStar GitHub Connection
1. AWS Console → **Developer Tools → Connections → Create connection**
2. Select **GitHub**, name it `github-eks-platform`
3. Click **Connect to GitHub** and authorise
4. Copy the Connection ARN – you'll need it in the next step

#### 4b. Deploy the pipeline stack
```bash
aws cloudformation deploy \
  --template-file cicd/pipeline.yaml \
  --stack-name eks-platform-pipeline \
  --region ca-west-1 \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
      GitHubOwner=YOUR_GITHUB_USERNAME \
      GitHubRepo=terraform-aws-eks-platform \
      GitHubBranch=main \
      CodeStarConnectionArn=arn:aws:codestar-connections:ca-west-1:ACCOUNT_ID:connection/XXXX \
      AlertEmail=ravionline86@gmail.com
```

#### 4c. What happens after deployment
1. Every push to `main` triggers the pipeline automatically
2. You get an email to approve before `terraform apply` runs (safety gate)
3. After approval: Terraform provisions EKS, then Helm deploys nginx-app + flask-app

---

## Part 5 – How to Make Code Changes (Daily Workflow)

```bash
# Always start from latest main
git checkout main
git pull

# Create a feature branch
git checkout -b feature/add-monitoring

# Make your changes, then stage and commit
git add .
git commit -m "Add Prometheus scrape config to flask-app"

# Push branch to GitHub
git push origin feature/add-monitoring

# On GitHub: open a Pull Request from feature/add-monitoring → main
# GitHub Actions will automatically run helm-lint and terraform-plan
# Review the PR, merge it → CodePipeline picks it up
```

---

## Part 6 – Repository Structure Reference

```
terraform-aws-eks-platform/
├── README.md                          ← Project overview (rendered on GitHub homepage)
├── FREE_TIER_TESTING.md               ← How to test without AWS cost
├── GITHUB_SETUP.md                    ← This file
├── .gitignore                         ← Files Git will never track
│
├── terraform/
│   ├── modules/
│   │   ├── vpc/                       ← VPC, subnets, NAT Gateway
│   │   ├── eks/                       ← EKS control plane + node group
│   │   ├── iam/                       ← All IAM roles and policies
│   │   └── cloudwatch/                ← Alarms, dashboards, log groups
│   └── envs/
│       └── staging/
│           ├── main.tf                ← Wires all modules together
│           ├── variables.tf
│           ├── outputs.tf
│           └── terraform.tfvars.example
│
├── helm/
│   ├── nginx-app/                     ← Nginx Helm chart
│   └── flask-app/                     ← Python Flask Helm chart
│
├── app/
│   ├── app.py                         ← Flask microservice
│   ├── requirements.txt
│   └── Dockerfile                     ← Multi-stage build
│
├── cicd/
│   └── pipeline.yaml                  ← CloudFormation stack: CodePipeline + CodeBuild
│
└── .github/
    └── workflows/
        ├── terraform-plan.yml         ← Validates Terraform on every PR
        ├── helm-lint.yml              ← Lints Helm charts on every PR
        └── flask-build-test.yml       ← Builds + tests Flask app on every PR
```

---

## Common Git Commands Cheat Sheet

```bash
git status                    # See what files changed
git diff                      # See exact changes
git log --oneline             # View commit history
git checkout main             # Switch back to main branch
git pull                      # Get latest changes from GitHub
git stash                     # Temporarily save uncommitted changes
git stash pop                 # Restore stashed changes
```
