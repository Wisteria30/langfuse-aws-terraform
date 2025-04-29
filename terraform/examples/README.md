# Example Using Terraform Modules

This example demonstrates how to use the `langfuse` module to deploy Langfuse core components on AWS.

## Pre-requisites

- Set your AWS credentials using terraform

## Usage

```bash
# Initialize Terraform
terraform init -backend-config "bucket=your-terraform-backend"
terraform plan
terraform apply
```