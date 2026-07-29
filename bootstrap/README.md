# Terraform Bootstrap Project - Amazon Bedrock RAG Chatbot

This directory contains the **Terraform Bootstrap Project** for the Amazon Bedrock RAG Chatbot on AWS.

The Bootstrap project is a **standalone, lightweight Terraform module** responsible solely for provisioning the secure AWS S3 backend infrastructure required to store and manage Terraform remote state for the main infrastructure project (`terraform/`).

---

## Architecture & Design Explanation

### 1. What Terraform State Is
Terraform state (`terraform.tfstate`) is a managed JSON file that serves as a single source of truth mapping declared infrastructure code (HCL) to real-world cloud resources provisioned in your AWS account. It stores physical resource IDs, metadata, outputs, and explicit/implicit resource dependency graphs.

### 2. Why Terraform Stores Infrastructure State
- **Resource Mapping**: HCL code defines logical resource names (e.g. `aws_s3_bucket.terraform_state`), while AWS identifies resources by unique physical IDs (e.g. `bedrock-rag-chatbot-dev-tfstate-a1b2c3d4`). State maps logical declarations to physical cloud resources.
- **Performance Optimization**: Storing state locally or remotely avoids querying cloud APIs for hundreds of resources on every operation, avoiding API rate limits and reducing plan execution time.
- **Dependency Graph Management**: State tracks creation, update, and destruction dependency chains.
- **Drift Detection**: Terraform compares configuration code, recorded state, and live AWS APIs to detect configuration drift and compute exact plan actions.

### 3. Why Remote State Is Required
- **Team Collaboration**: Local state files prevent multiple engineers or automated CI/CD runners from collaborating safely.
- **Security & Secret Protection**: State files contain plain-text attributes (database credentials, IAM outputs, connection strings). Remote backends allow encrypting state at rest and restricting access using IAM policies without risking state exposure in Git repositories.
- **Concurrency & State Locking**: Prevents concurrent Terraform runs from executing simultaneously, avoiding state corruption or conflicting changes.
- **Durability**: Remote state in AWS S3 protects state history against local hardware failures or accidental file deletion.

### 4. Why S3 Is the Recommended Backend
- **11 Nines Durability**: AWS S3 provides 99.999999999% durability across multiple Availability Zones.
- **State Versioning**: Built-in object versioning keeps full historical versions of state modifications, allowing easy state restoration if needed.
- **Robust Security**: Full integration with AWS IAM, AES256 server-side encryption, TLS in transit, object ownership controls, and Public Access Block rules.
- **Zero Overhead**: Fully managed serverless storage with no underlying database management.

### 5. Why Terraform Cannot Automatically Create Its Own Backend
- **The Chicken-and-Egg Dilemma**: For Terraform to store state in an S3 bucket, that bucket must already exist. If `backend "s3"` is configured in a project before the bucket is created, `terraform init` fails immediately because the state storage target does not exist.
- **Lifecycle Separation**: Storage infrastructure for state management must exist prior to initializing any main project state.

### 6. Why Production Environments Create Backend Resources Separately
- **Lifecycle Isolation**: State storage infrastructure must outlive application components.
- **Blast Radius Protection**: A destructive `terraform destroy` command run on application infrastructure should never delete the remote state storage bucket containing state history.
- **Strict IAM Governance**: Provisions backend resources under dedicated administrative privileges while restricting day-to-day deployment roles.

### 7. What State Locking Is
State locking places a lock on the remote state during mutating operations (`terraform plan`, `apply`, `destroy`). It ensures that only one operation modifies the state file at any given time, preventing race conditions and corrupted states.

### 8. DynamoDB State Locking vs. S3 Native Lockfile
- **DynamoDB State Locking (Legacy)**: Required creating an Amazon DynamoDB table with a `LockID` primary key. Terraform wrote lock items to DynamoDB during runs. This required managing an additional AWS service and adding DynamoDB IAM permissions.
- **S3 Native Lockfile (Modern - Terraform >= 1.15)**: Terraform utilizes native S3 strong consistency and conditional write headers (`PutObject` with `.tflock` files) to perform locking directly inside the state S3 bucket without requiring DynamoDB.

### 9. Why S3 Native Lockfile (`use_lockfile = true`) Is Preferred
- **Zero Extra Infrastructure**: No DynamoDB table needs to be provisioned, monitored, or paid for.
- **Simplified IAM Policies**: IAM roles require S3 access only; no DynamoDB permissions (`dynamodb:GetItem`, `PutItem`, `DeleteItem`) are needed.
- **Native Consistency**: Capitalizes on Amazon S3's strong read-after-write consistency model.

### 10. Complete Lifecycle of Terraform State After Bootstrap
1. **Provision Bootstrap**: Apply this bootstrap project locally (`bootstrap/`) to create the S3 state bucket.
2. **Configure Main Project**: Specify `backend "s3"` in `terraform/backend.tf` using the bucket created by bootstrap and setting `use_lockfile = true`.
3. **Migrate State**: Run `terraform init` in `terraform/` to transfer initial local state to the remote S3 bucket.
4. **Ongoing Management**: All subsequent `terraform plan` and `terraform apply` operations in `terraform/` automatically lock state using S3 native lockfiles and write versioned state snapshots to S3.

---

## Directory Structure

```
bootstrap/
├── versions.tf               # Terraform CLI (>= 1.15.0) and provider constraints
├── providers.tf              # AWS provider configuration and default_tags
├── variables.tf              # Input variables with validation and defaults
├── main.tf                   # Primary S3 bucket & security configurations
├── outputs.tf                # Exported bucket name, ARN, and backend config snippet
├── terraform.tfvars.example  # Sample variable overrides
└── README.md                 # Project documentation
```

---

## Terraform Workflow

### Step 1: Initialize Bootstrap Module
Initialize the local working directory to download the required AWS and Random providers:
```bash
cd bootstrap
terraform init
```

### Step 2: Validate Configuration Syntax
Validate HCL code formatting and configuration validity:
```bash
terraform validate
```

### Step 3: Preview Execution Plan
Review the proposed AWS resources that will be provisioned:
```bash
terraform plan
```

### Step 4: Apply Configuration
Provision the backend S3 bucket:
```bash
terraform apply
```

Upon successful apply, Terraform will output the bucket name and the exact backend configuration snippet needed for the main project.

---

## Verifying the Backend Bucket

Verify the created S3 bucket using the AWS CLI:

```bash
# Get bucket name from Terraform outputs
BUCKET_NAME=$(terraform output -raw s3_bucket_name)

# 1. Verify bucket exists and public access is blocked
aws s3api get-public-access-block --bucket $BUCKET_NAME

# 2. Verify bucket versioning is enabled
aws s3api get-bucket-versioning --bucket $BUCKET_NAME

# 3. Verify server-side encryption configuration
aws s3api get-bucket-encryption --bucket $BUCKET_NAME
```

---

## Configuring `backend.tf` in Main Project

Copy the output `backend_config_instructions` into `terraform/backend.tf` inside the main infrastructure folder:

```hcl
terraform {
  backend "s3" {
    bucket       = "<s3_bucket_name_from_bootstrap_output>"
    key          = "bedrock-rag-chatbot/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}
```

---

## Migrating State to Remote Backend

Navigate to the main Terraform directory (`terraform/`) and run:

```bash
cd ../terraform
terraform init
```

Terraform will detect the newly added S3 backend and prompt:
> *Do you want to copy existing state to the new backend?*

Type **`yes`**. Terraform will copy your state file into the remote S3 bucket.

---

## Destroying the Bootstrap Project Safely

> [!CAUTION]
> The bootstrap S3 bucket contains the state files for your main infrastructure. Destroying this bucket while active infrastructure exists will result in loss of state management.

To prevent accidental deletion, the bucket resource includes `lifecycle { prevent_destroy = true }`.

If you ever intentionally need to destroy the bootstrap bucket:
1. Ensure all main infrastructure (`terraform/`) has been completely destroyed (`terraform destroy`).
2. Migrate or clear the remote state.
3. In `bootstrap/main.tf`, temporarily set `prevent_destroy = false` or remove the lifecycle block.
4. Run `terraform destroy` in `bootstrap/`.
