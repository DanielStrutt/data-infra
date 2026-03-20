# data-infra

Terraform infrastructure repo for AWS.

## GitHub Actions Workflows

This repository uses GitHub Actions to automate Terraform planning and deployment for both dev and prod environments. The workflows are located in `.github/workflows/` and include:

- **dev-plan.yml**: Runs on every push to the `dev` branch. It checks out the code, sets up Terraform and AWS credentials, runs `terraform init` and `terraform plan` with the dev environment variables, and uploads the plan as an artifact.

- **dev-apply.yml**: Can be triggered manually (workflow_dispatch) and requires confirmation. It validates the confirmation input, checks out the code, sets up Terraform and AWS credentials, re-initializes Terraform, and runs a plan before applying changes to the dev environment.

- **prod-plan.yml**: Runs on pull requests targeting the `main` branch. It checks out the code, sets up Terraform and AWS credentials, runs `terraform init` and `terraform plan` with the prod environment variables, and posts the plan output as a comment on the PR. This helps review infrastructure changes before merging to production.

- **prod-apply.yml**: Runs automatically on every push to the `main` branch. It checks out the code, sets up Terraform and AWS credentials, runs `terraform init`, creates a plan, and then applies the plan to the prod environment.

**Summary:**

- All changes to infrastructure are planned and reviewed before being applied.
- Dev changes are applied manually with confirmation, while prod changes require a PR and are applied automatically after merging to `main`.
- AWS credentials are managed via GitHub secrets.
- Plans and applies are always run with the correct environment-specific variables and state files.

---

## Prerequisites and Setup

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.0
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) v2
- An AWS IAM user with programmatic access (access key + secret)

> **After a `winget` install**, open a **new** terminal so PATH is refreshed before running `aws` or `terraform`.

---

## 1. Configure AWS credentials

In the AWS console, go to **IAM → Users → terraform → Security credentials → Create access key**.  
Choose **CLI** as the use case and save the key ID and secret somewhere safe.

Then run:

```bash
aws configure
```

You'll be prompted for:

| Prompt | Value |
|---|---|
| AWS Access Key ID | From the console |
| AWS Secret Access Key | From the console |
| Default region name | e.g. `us-east-1` |
| Default output format | `json` |

Verify it works:

```bash
aws sts get-caller-identity
```

You should see your account ID and the `terraform` user ARN.

---

## 2. Initialise and apply

Environment-specific tfvars live in `envs/dev/` and `envs/prod/`. Pass the relevant file at plan/apply time:

```bash
# Initialise (only needed once, or after adding new modules/providers)
terraform init

# Deploy to dev
terraform plan  -var-file="envs/dev/terraform.tfvars"
terraform apply -var-file="envs/dev/terraform.tfvars"

# Deploy to prod
terraform plan  -var-file="envs/prod/terraform.tfvars"
terraform apply -var-file="envs/prod/terraform.tfvars"
```

This will create resources named `data-infra-dev-*` or `data-infra-prod-*` depending on which tfvars you use.

NOTE: This should only be done once on set up. Changes to both Dev and Prod should only be done via Github Actions pipelines.

---

## Repository structure

```
.
├── main.tf              # Calls modules, references locals
├── providers.tf         # Terraform + AWS provider config + S3 backend
├── variables.tf         # Input variable declarations
├── locals.tf            # Derives resource name prefix (e.g. data-infra-dev)
├── outputs.tf           # Root outputs
├── .gitignore
├── modules/
│   └── s3/
│       ├── main.tf      # S3 bucket + versioning + encryption + public access block
│       ├── variables.tf
│       └── outputs.tf
└── envs/
    ├── dev/
    │   └── terraform.tfvars   # environment = "dev"
    └── prod/
        └── terraform.tfvars   # environment = "prod"
```

### How naming works

`locals.tf` builds a prefix from the tfvars you pass in:

```hcl
locals {
  name_prefix = "${var.project_name}-${var.environment}"  # → data-infra-dev
}
```

That prefix is passed into each module, so resources are automatically named `data-infra-dev-bucket`, `data-infra-prod-bucket`, etc.

---