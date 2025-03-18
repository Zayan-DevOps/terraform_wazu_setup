# Terraform Setup Guide

This guide will help you set up and deploy your infrastructure using Terraform on AWS.

## Prerequisites
- AWS account
- AWS CLI installed and configured
- Terraform installed on your system
- Ubuntu AMI ID for `us-east-1` region

## Steps to Deploy

### 1. Configure AWS CLI
Ensure AWS CLI is installed and configured with your AWS account:
```sh
aws configure
```
Provide the necessary details (Access Key, Secret Key, Region, and Output Format).

### 2. Create an S3 Bucket
Create an S3 bucket in the `us-east-1` region for Terraform state storage:
```sh
aws s3api create-bucket --bucket <your-unique-bucket-name> --region us-east-1 --create-bucket-configuration LocationConstraint=us-east-1
```

### 3. Update `backend.tf`
Modify `backend.tf` to include your newly created S3 bucket name:
```hcl
terraform {
  backend "s3" {
    bucket = "<your-unique-bucket-name>"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
```

### 4. Update `variables.tf`
Set the Ubuntu AMI ID in `variables.tf` for `us-east-1`:
```hcl
variable "ami" {
  type    = string
  default = "<ubuntu-latest-image>"
}
```

### 5. Initialize Terraform
Run the following command to initialize Terraform:
```sh
terraform init
```

### 6. Plan Terraform Deployment
Check the execution plan before applying changes:
```sh
terraform plan
```

### 7. Validate Terraform Configuration
Ensure the Terraform configuration files are valid:
```sh
terraform validate
```

### 8. Apply Terraform Configuration
Deploy your infrastructure automatically:
```sh
terraform apply --auto-approve
```

### 9. Access the Dashboard
Once the deployment is successful, access the dashboard by pasting the following in your browser:
```
https://<ec2_public_ip>:443/
```
Replace `<ec2_public_ip>` with your EC2 instance's public IP.

## Cleanup
To destroy the deployed infrastructure when no longer needed, run:
```sh
terraform destroy --auto-approve
```

## Troubleshooting
- Ensure AWS CLI is correctly configured.
- Double-check your S3 bucket name in `backend.tf`.
- Verify your Ubuntu AMI ID is correct for the `us-east-1` region.
- If you face network issues, ensure security group rules allow access on port `443`.

## Conclusion
This guide helps you deploy an infrastructure using Terraform with AWS. Happy automating!

