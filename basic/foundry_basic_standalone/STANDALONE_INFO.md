# Foundry Basic Standalone Export

This directory contains a complete, standalone version of the CAIRA foundry_basic reference architecture with all required modules included locally.

## What's Included

This standalone export includes:

### Core Configuration Files
- `main.tf` - Main Terraform configuration with updated module paths
- `variables.tf` - Input variables for the configuration
- `outputs.tf` - Output values from the deployment
- `terraform.tf` - Provider requirements and configuration
- `dependant_resources.tf` - Supporting resources (Log Analytics, App Insights)

### Local Modules
- `modules/ai_foundry/` - Complete AI Foundry module with all dependencies
- `modules/common_models/` - Model deployment specifications module

### Documentation and Support
- `README.md` - Updated deployment guide for standalone use
- `CHANGELOG.md` - Version history and changes
- `images/` - Architecture diagrams and documentation images
- `tests/` - Test configurations and validation scripts

## Key Differences from Original

1. **Module Sources**: Updated to use local module paths (`./modules/...`) instead of relative paths to the CAIRA repository
2. **Self-Contained**: All required modules are included locally, eliminating external dependencies
3. **Standalone Deployment**: Can be deployed independently without the full CAIRA repository

## Deployment

This configuration can be deployed just like any standard Terraform configuration:

```bash
# Initialize Terraform
terraform init

# Review the deployment plan
terraform plan

# Deploy the infrastructure
terraform apply
```

## Benefits of Standalone Export

- **Independence**: No dependency on external repository structure
- **Portability**: Can be easily shared or moved to different environments
- **Version Control**: Each export captures a specific version of modules
- **Simplified Distribution**: Easier to distribute to teams or customers

## Module Versions

This export was created from the CAIRA repository and includes the following modules:

- AI Foundry Module: Latest version at time of export
- Common Models Module: Latest version at time of export

For the most up-to-date versions, refer to the original CAIRA repository.