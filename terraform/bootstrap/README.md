# Terraform Bootstrap

This directory contains the bootstrap step for the Terraform remote state backend.

## Purpose

The bootstrap project creates the Amazon S3 bucket that stores the Terraform state for the main infrastructure project.

## Files

- versions.tf: Terraform and provider version constraints
- providers.tf: AWS provider configuration
- variables.tf: Input variables with validation
- main.tf: S3 bucket and security resources
- outputs.tf: Outputs for the backend bucket and backend block example
- terraform.tfvars.example: Example variable values

## Workflow

Run these commands from this folder:

```bash
terraform init
terraform plan
terraform apply
```

After apply, use the `backend_config_example` output to configure the main project backend.
