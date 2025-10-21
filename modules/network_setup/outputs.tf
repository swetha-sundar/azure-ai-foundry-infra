# Network Outputs
# Outputs for Virtual Network and subnet resources that can be used by other configurations

# Resource Group Outputs
output "network_resource_group_id" {
  description = "The resource ID of the network resource group."
  value       = var.create_network_resource_group ? azurerm_resource_group.network[0].id : data.azurerm_resource_group.network[0].id
}

output "network_resource_group_name" {
  description = "The name of the network resource group."
  value       = local.network_resource_group_name
}

# Virtual Network Outputs
output "vnet_id" {
  description = "The resource ID of the virtual network."
  value       = azurerm_virtual_network.foundry_vnet.id
}

output "vnet_name" {
  description = "The name of the virtual network."
  value       = azurerm_virtual_network.foundry_vnet.name
}

output "vnet_address_space" {
  description = "The address space of the virtual network."
  value       = azurerm_virtual_network.foundry_vnet.address_space
}

# Foundry Subnet Outputs
output "foundry_subnet_id" {
  description = "The resource ID of the foundry subnet. Use this value for the foundry_subnet_id variable in the AI Foundry configuration."
  value       = azurerm_subnet.foundry_subnet.id
}

output "foundry_subnet_name" {
  description = "The name of the foundry subnet."
  value       = azurerm_subnet.foundry_subnet.name
}

output "foundry_subnet_address_prefixes" {
  description = "The address prefixes of the foundry subnet."
  value       = azurerm_subnet.foundry_subnet.address_prefixes
}

# Agent Subnet Outputs
output "agent_subnet_id" {
  description = "The resource ID of the agent subnet. Use this value for the agents_subnet_id variable in the AI Foundry configuration."
  value       = azurerm_subnet.agent_subnet.id
}

output "agent_subnet_name" {
  description = "The name of the agent subnet."
  value       = azurerm_subnet.agent_subnet.name
}

output "agent_subnet_address_prefixes" {
  description = "The address prefixes of the agent subnet."
  value       = azurerm_subnet.agent_subnet.address_prefixes
}

# Network Security Group Outputs (conditional)
output "foundry_nsg_id" {
  description = "The resource ID of the foundry subnet network security group."
  value       = var.create_network_security_groups ? azurerm_network_security_group.foundry_nsg[0].id : null
}

output "agent_nsg_id" {
  description = "The resource ID of the agent subnet network security group."
  value       = var.create_network_security_groups ? azurerm_network_security_group.agent_nsg[0].id : null
}

# Route Table Outputs (conditional)
output "foundry_route_table_id" {
  description = "The resource ID of the foundry subnet route table."
  value       = var.create_route_tables ? azurerm_route_table.foundry_rt[0].id : null
}

output "agent_route_table_id" {
  description = "The resource ID of the agent subnet route table."
  value       = var.create_route_tables ? azurerm_route_table.agent_rt[0].id : null
}

# Convenient Combined Outputs for AI Foundry Configuration
output "ai_foundry_network_config" {
  description = "Network configuration values to use directly in AI Foundry terraform.tfvars."
  value = {
    foundry_subnet_id = azurerm_subnet.foundry_subnet.id
    agents_subnet_id  = azurerm_subnet.agent_subnet.id
  }
}
