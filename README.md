# Azure AI Foundry Infrastructure Setup

It contains all the necessary modules and code to deploy a private networking enabled AI Foundry environment.

## Overview

This configuration is suited for:

- **Enterprise/regulated workloads** that require private networking and enhanced security controls
- **Organizations with existing Azure services** that need to integrate AI Foundry with their current Cosmos DB, Storage, and AI Search resources
- **Teams with strict network security requirements** that mandate subnet injection and private endpoint connectivity
- **Environments that need both data sovereignty and network isolation** with RBAC-based access controls

## Infrastructure/Architecture Components

| Component                                          | Purpose                            | Configuration                                                                                     |
|----------------------------------------------------|------------------------------------|---------------------------------------------------------------------------------------------------|
| **Resource Group**                                 | Logical container for resources    | Created if not provided; can use existing resource group via `resource_group_resource_id`         |
| **Azure AI Foundry Account and Project**           | Core AI platform resources         | Deployed via Terraform module; project identity managed automatically; private networking enabled |
| **Model Deployments**                              | Provides default models for agents | Uses `common_models` module; includes GPT‑4.1 model deployment  and Embedding model                                  |
| **Log Analytics Workspace + Application Insights** | Monitoring and observability       | App Insights connected to Log Analytics Workspace; deployed and wired automatically               |
| **Existing Azure Cosmos DB Account**               | Data storage for agent specific data           | References existing Cosmos DB via data source; explicitly wired via host connections              |
| **Existing Azure Storage Account**                 | File and blob storage for agents   | References existing Storage Account via data source; explicitly wired via host connections        |
| **Existing Azure AI Search Service**               | Search capabilities for agents     | References existing AI Search service via data source; explicitly wired via host connections      |
| **Virtual Network Integration**                    | Private networking                 | AI Foundry injected into `foundry_subnet_id`; Agents injected into `agents_subnet_id`             |

## Key Features

- **🔒 Private networking**: AI Foundry and agents are injected into your existing VNet subnets for enhanced security
- **🌍 Existing resource integration**: Uses your existing Cosmos DB, Storage, and AI Search resources for complete control
- **🛡️ Enhanced security**: Private endpoints and subnet injection eliminate public internet exposure
- **📊 Observability**: Log Analytics and Application Insights out of the box
- **📈 Enterprise-ready**: Built for regulated workloads with strict security and compliance requirements

## Prerequisites

### 1. Existing Capability Host Resources

- **Azure Cosmos DB Account**: Existing Cosmos DB account for agent data storage
- **Azure Storage Account**: Existing Storage Account for file and blob storage
- **Azure AI Search Service**: Existing AI Search service for search capabilities
- All existing resources must be in the same region as the AI Foundry deployment

### 2. Azure Permissions

Active Azure subscription(s) with appropriate permissions for the target resource group and services. Suggested roles include:

- **Workload Subscription**
  - **Role Based Access Control Administrator**: Needed over the resource group to create the relevant role assignments
  - **Network Contributor**: Needed over the resource group and VNet to create private endpoint resources
  - **Azure AI Account Owner**: Needed to create a cognitive services account and project
  - **Owner or Role Based Access Administrator**: Needed to assign RBAC to the existing resources (Cosmos DB, Azure AI Search, Storage)
  - **Azure AI User**: Needed to create and edit agents
  - **Cognitive Services OpenAI Contributor**: Needed to write OpenAI responses API

### 3. Register Resource Providers

```shell
az provider register --namespace 'Microsoft.App'
az provider register --namespace 'Microsoft.CognitiveServices'
az provider register --namespace 'Microsoft.DocumentDB'
az provider register --namespace 'Microsoft.Search'
az provider register --namespace 'Microsoft.Storage'
az provider register --namespace 'Microsoft.Network'
```

### 4. Tools Requirements

- Sufficient quota for all resources in your target Azure region
- Azure CLI installed and configured on your local workstation or deployment pipeline server
- Terraform CLI version v1.13 or later on your local workstation or deployment pipeline server

## Deployment Instructions

### 1. Login to Azure

```shell
az login
```

### 2. Set Active Subscription

```shell
az account set --subscription "<your_subscription_id>"
```

### 3. Export Subscription ID

```shell
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
```

### 4. Initialize Terraform

```shell
terraform init
```

NOTE: if you already have an existing Network you want to reuse, skip Step 5

### 5. Configure Network Variables

1. Go to modules/network_setup folder
2. Copy the terraform.tfvars.example file to terraform.tfvars and update the values for your environment

### 6. Review and Deploy Network

1. Follow instructions in [Readme in network_setup module](./modules/network_setup/README.md) to deploy the virtual network and subnets
2. Copy the output variables "foundry_subnet_id" and "agent_subnet_id" to the root folder's terraform.tfvars file

#### 6-a. Create Private DNS zones

```bash
   az network private-dns zone create \
     --resource-group <your-network-resource-group> \
     --name privatelink.cognitiveservices.azure.com

   az network private-dns zone create \
     --resource-group <your-network-resource-group> \
     --name privatelink.services.ai.azure.com

   az network private-dns zone create \
     --resource-group <your-network-resource-group> \
     --name privatelink.openai.azure.com
```

#### 6-b. Link the DNS zones with the Virtual Network created

 ```bash
   az network private-dns link vnet create \
     --resource-group <your-network-resource-group> \
     --zone-name privatelink.cognitiveservices.azure.com \
     --name cognitive-services-vnet-link \
     --virtual-network fin-analyst-vnet \
     --registration-enabled false

   az network private-dns link vnet create \
     --resource-group <your-network-resource-group> \
     --zone-name privatelink.services.ai.azure.com \
     --name ai-services-vnet-link \
     --virtual-network fin-analyst-vnet \
     --registration-enabled false

   az network private-dns link vnet create \
     --resource-group <your-network-resource-group> \
     --zone-name privatelink.openai.azure.com \
     --name openai-vnet-link \
     --virtual-network fin-analyst-vnet \
     --registration-enabled false
   ```

### 7. Configure the variables for AI Foundry

1. Go to root folder
2. Copy the terraform.tfvars.example file to terraform.tfvars and update the values for your environment
3. Ensure you update the subnet ids with the above output values from the previous step

### 8. Review and Deploy Network

```shell
# Review the deployment plan
terraform plan

# Deploy the infrastructure
terraform apply
```

## Included Modules

This extracted folder contains the following modules with all dependencies:

### `/modules/ai_foundry`

Core AI Foundry module that provisions:

- Azure AI Foundry Account
- AI Foundry Project
- Model deployments
- Private networking configuration
- Role assignments for capability host connections

### `/modules/common_models`

Standardized AI model deployment specifications including:

- GPT-4.1 model
- GPT-4o mini model
- Text embedding model

### `/modules/existing_resources_agent_capability_host_connections`

Module for connecting to existing Azure services:

- Azure Cosmos DB integration
- Azure Storage Account integration
- Azure AI Search integration

## Configuration Options

### Required Variables

| Variable | Description |
|----------|-------------|
| `agents_subnet_id` | The subnet ID where AI Foundry Agents will be injected |
| `foundry_subnet_id` | The subnet ID for the AI Foundry private endpoints |
| `existing_capability_host_resource_group_id` | Resource group ID containing existing resources |
| `existing_cosmosdb_account_name` | Name of existing Cosmos DB account |
| `existing_storage_account_name` | Name of existing Storage Account |
| `existing_search_service_name` | Name of existing Azure AI Search service |

### Optional Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `location` | `"swedencentral"` | Azure region for deployment |
| `resource_group_resource_id` | `null` | Existing resource group ID (creates new if null) |
| `project_name` | `"default-project"` | AI Foundry project name |
| `project_display_name` | `"Default Project"` | AI Foundry project display name |
| `project_description` | `"Default Project description"` | AI Foundry project description |
| `sku` | `"S0"` | AI Foundry resource SKU |
| `tags` | `null` | Tags to apply to all resources |

## Outputs

| Output | Description |
|--------|-------------|
| `ai_foundry_id` | Resource ID of the AI Foundry account |
| `ai_foundry_name` | Name of the AI Foundry account |
| `ai_foundry_endpoint` | Endpoint URL of the AI Foundry account |
| `ai_foundry_project_id` | Resource ID of the AI Foundry Project |
| `ai_foundry_project_name` | Name of the AI Foundry Project |
| `ai_foundry_project_identity_principal_id` | Principal ID of the project managed identity |
| `agent_capability_host_connections` | Connections used for agent capability host |
| `application_insights_id` | Resource ID of Application Insights |
| `log_analytics_workspace_id` | Resource ID of Log Analytics workspace |
| `resource_group_id` | Resource ID of the resource group |

## Private Networking Configuration

This configuration enables private networking by default with:

- **Subnet injection**: Both AI Foundry service and Agents are injected into your specified subnets
- **Public access disabled**: All communication flows through your private network
- **Private endpoints**: Secure connectivity to Azure services within your VNet

Ensure your existing Cosmos DB, Storage, and AI Search services are configured appropriately for private access if needed.

## Troubleshooting

### Common Issues

**Subnet configuration errors**

- Verify that `agents_subnet_id` and `foundry_subnet_id` are valid subnet resource IDs
- Ensure subnets exist in your VNet and have proper network policies configured

**Existing resource errors**

- Confirm resource names and resource group IDs are correct
- Ensure the project identity has required RBAC on existing resources
- Verify all existing resources are in the same Azure region

**Private networking issues**

- Check that existing resources are accessible from specified subnets
- Review network security group rules and route tables
- Ensure private DNS configuration is correct

**Quota/region issues**

- Check model availability in your target region
- Verify service quotas for all required resources

**Provider registration**

- Validate all required providers are registered
- Run `terraform validate` to check configuration

### Validation Commands

```shell
# Validate Terraform configuration
terraform validate

# Check Azure CLI context
az account show

# Verify resource providers
az provider list --query "[?registrationState=='Registered'].namespace" -o table
```

## Cost Considerations

This configuration provisions:

- Azure AI Foundry Account and Project
- Log Analytics Workspace (30-day retention)
- Application Insights
- Model deployments

Review SKUs and retention settings to optimize costs. The configuration uses existing Cosmos DB, Storage, and AI Search resources, so additional costs for those services depend on your existing configuration.

## Security Considerations

- Private networking eliminates public internet exposure
- Role assignments follow principle of least privilege
- All communication flows through your controlled network boundaries
- Monitor access through Application Insights and Log Analytics

## Support

For issues specific to this extracted configuration:

1. Verify all prerequisites are met
1. Check troubleshooting section above
1. Validate configuration with `terraform validate`
1. Review Azure resource quotas and permissions

## License

Copyright (c) Microsoft Corporation. Licensed under the MIT license.

## Troubleshooting Guide

If you run into issues:

**Error:**

``` bash
│ Error: Failed to create/update resource
│
│   with module.ai_foundry.azapi_resource.ai_foundry,
│   on modules/ai_foundry/main.tf line 3, in resource "azapi_resource" "ai_foundry":
│    3: resource "azapi_resource" "ai_foundry" {
│
│ creating/updating Resource: (ResourceId
│ "/subscriptions/subscription-id/resourceGroups/rg-finanalyst-private-zriti/providers/Microsoft.CognitiveServices/accounts/cog-finanalyst-private-zriti"
│ / Api Version "2025-06-01"): PUT
│ https://management.azure.com/subscriptions/a8d2b99a-0f7d-4f8d-9510-bcfc5bacf47f/resourceGroups/rg-finanalyst-private-zriti/providers/Microsoft.CognitiveServices/accounts/cog-finanalyst-private-zriti
│ --------------------------------------------------------------------------------
│ RESPONSE 409: 409 Conflict
│ ERROR CODE: FlagMustBeSetForRestore
--------------------------------------------------------------------------------
│ {
│   "error": {
│     "code": "FlagMustBeSetForRestore",
│     "message": "An existing resource with ID '/subscriptions/subscriptionid/resourceGroups/rg-finanalyst-private-zriti/providers/Microsoft.CognitiveServices/accounts/cog-finanalyst-private-zriti' has been soft-deleted. To restore the resource, you must specify 'restore' to be 'true' in the property. If you don't want to restore existing resource, please purge it first."
│   }
│ }
│ --------------------------------------------------------------------------------
│
```

**Solution:**

``` bash
az cognitiveservices account purge --resource-group <ai-foundry-resource-group> --name <name of the foundry account> --location eastus
```