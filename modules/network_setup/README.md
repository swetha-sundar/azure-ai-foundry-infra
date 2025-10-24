# Network Configuration for Azure AI Foundry Standard Private

This directory contains Terraform configuration to create the virtual network infrastructure required for the Azure AI Foundry Standard Private deployment.

## Overview

This configuration creates:

- **Virtual Network**: A VNet with configurable address space
- **Foundry Subnet**: Subnet for AI Foundry private endpoints with proper network policies
- **Agent Subnet**: Subnet for AI Foundry Agents with Container Apps delegation
- **Network Security Groups**: Basic security rules for both subnets (optional)
- **Route Tables**: Custom routing configuration (optional)

## Prerequisites

1. **Azure CLI** installed and configured
1. **Terraform** version 1.13 or later
1. **Azure permissions** to create networking resources
1. **Active Azure subscription**

## Quick Start

### 1. Deploy Network Infrastructure

If you want to use an existing network, skip and go to step 3

```bash
# Navigate to the network configuration directory
cd /path/to/modules/network_setup

# Initialize Terraform (only for network resources)
terraform init -upgrade

# Copy and customize the network configuration
cp terraform.tfvars.example terraform.tfvars
# Edit network.tfvars with your specific values

# Deploy the network infrastructure
terraform plan -var-file="terraform.tfvars" -target="azurerm_virtual_network.foundry_vnet" -target="azurerm_subnet.foundry_subnet" -target="azurerm_subnet.agent_subnet"
terraform apply -var-file="terraform.tfvars" -target="azurerm_virtual_network.foundry_vnet" -target="azurerm_subnet.foundry_subnet" -target="azurerm_subnet.agent_subnet"
```

### 2. Get Subnet IDs for AI Foundry Configuration

```bash
# Get the subnet IDs after deployment
terraform output ai_foundry_network_config
```

### [Optional] 3. Existing Network Infrastructure

Follow this step only if you want to use your existing virtual network and subnets

- **Virtual Network**: An existing VNet with two subnets available for AI Foundry and Agents injection
- **Foundry Subnet**: Subnet ID where the AI Foundry service will be injected
- **Agents Subnet**: Subnet ID where AI Foundry Agents will be injected

### 4. Use in AI Foundry Configuration

Copy the subnet IDs to your main `terraform.tfvars` file:

```hcl
# In your main terraform.tfvars file
foundry_subnet_id = "/subscriptions/.../subnets/foundry-subnet"
agents_subnet_id  = "/subscriptions/.../subnets/agent-subnet"
```

## Configuration Options

### Required Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `project_name` | Project name for resource naming | `"foundry-private"` |
| `location` | Azure region | `"swedencentral"` |

### Network Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `vnet_address_space` | VNet address space in CIDR | `"10.0.0.0/16"` |
| `foundry_subnet_address_prefix` | Foundry subnet CIDR | `"10.0.1.0/24"` |
| `agent_subnet_address_prefix` | Agent subnet CIDR | `"10.0.2.0/24"` |

### Optional Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `create_network_resource_group` | Create new resource group | `true` |
| `network_resource_group_name` | Existing RG name (if not creating new) | `null` |
| `vnet_name` | Custom VNet name | `null` (auto-generated) |
| `create_network_security_groups` | Create NSGs with security rules | `true` |
| `create_route_tables` | Create route tables | `false` |

## Network Architecture

```
Virtual Network (10.0.0.0/16)
├── foundry-subnet (10.0.1.0/24)
│   ├── Private endpoint network policies: Disabled
│   ├── Used for: AI Foundry private endpoints
│   └── NSG: Basic HTTPS and outbound rules
└── agent-subnet (10.0.2.0/24)
    ├── Private endpoint network policies: Disabled
    ├── Delegation: Microsoft.App/environments
    ├── Used for: AI Foundry Agents subnet injection
    └── NSG: Container Apps and HTTPS rules
```

## Security Configuration

When `create_network_security_groups = true`, the following security rules are created:

### Foundry Subnet NSG Rules

- **Inbound**: Allow HTTPS (443) from VNet address space
- **Outbound**: Allow all to Internet for Azure services

### Agent Subnet NSG Rules

- **Inbound**: Allow HTTPS (443) from VNet address space
- **Inbound**: Allow Container Apps communication within subnet
- **Outbound**: Allow all to Internet for Azure services

## Outputs

After deployment, the following outputs are available:

| Output | Description | Use Case |
|--------|-------------|----------|
| `foundry_subnet_id` | Foundry subnet resource ID | Use for `foundry_subnet_id` variable |
| `agent_subnet_id` | Agent subnet resource ID | Use for `agents_subnet_id` variable |
| `ai_foundry_network_config` | Combined network config | Copy values to main terraform.tfvars |

## Example Usage

### Basic Network Setup

```hcl
# network.tfvars
project_name = "my-ai-project"
location     = "eastus"
vnet_address_space = "172.16.0.0/16"
foundry_subnet_address_prefix = "172.16.1.0/24"
agent_subnet_address_prefix   = "172.16.2.0/24"
```

### Using Existing Resource Group

```hcl
# network.tfvars
create_network_resource_group = false
network_resource_group_name   = "existing-network-rg"
```

### Minimal Security Setup

```hcl
# network.tfvars
create_network_security_groups = false
create_route_tables            = false
```

## Validation

After deployment, validate the configuration:

```bash
# Check that subnets were created correctly
az network vnet subnet show --resource-group <rg-name> --vnet-name <vnet-name> --name foundry-subnet
az network vnet subnet show --resource-group <rg-name> --vnet-name <vnet-name> --name agent-subnet

# Verify subnet delegation for agent subnet
az network vnet subnet show --resource-group <rg-name> --vnet-name <vnet-name> --name agent-subnet --query "delegations"
```

## Troubleshooting

### Common Issues

**Subnet address conflicts**

- Ensure subnet CIDRs don't overlap
- Verify subnet CIDRs are within VNet address space

**Permission errors**

- Verify Network Contributor role on resource group
- Check subscription permissions for VNet creation

**Delegation errors**

- Agent subnet requires Microsoft.App/environments delegation
- This is automatically configured by the script

### Validation Commands

```bash
# Validate Terraform configuration
terraform validate

# Check Azure CLI context
az account show

# Verify resource provider registration
az provider show --namespace Microsoft.Network --query "registrationState"
```

## Integration with AI Foundry

After creating the network infrastructure:

1. **Copy subnet IDs** from terraform outputs
1. **Update main terraform.tfvars** with the subnet IDs
1. **Deploy AI Foundry** using the main configuration

The network configuration is designed to work seamlessly with the Azure AI Foundry Standard Private reference architecture.

## Clean Up

To remove the network infrastructure:

```bash
# Destroy network resources
terraform destroy -var-file="network.tfvars"
```

**Warning**: Ensure no resources are using the VNet before destroying it.