# Network Configuration Variables

variable "project_name" {
  type        = string
  description = "Project name used for resource naming conventions."
  default     = "foundry-private"
}

variable "location" {
  type        = string
  description = "Azure region where the network resources should be deployed."
  default     = "eastus"
  nullable    = false
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to be applied to all network resources."
}

# Resource Group Configuration
variable "create_network_resource_group" {
  type        = bool
  description = "Whether to create a new resource group for network resources. If false, use existing resource group specified in network_resource_group_name."
  default     = true
}

variable "network_resource_group_name" {
  type        = string
  description = "Name of the resource group for network resources. Required if create_network_resource_group is false."
  default     = null
}

# Virtual Network Configuration
variable "vnet_name" {
  type        = string
  description = "Name of the virtual network. If not provided, will be generated based on project_name."
  default     = null
}

variable "vnet_address_space" {
  type        = string
  description = "Address space for the virtual network in CIDR notation."
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vnet_address_space, 0))
    error_message = "The vnet_address_space must be a valid CIDR notation."
  }
}

# Foundry Subnet Configuration
variable "foundry_subnet_address_prefix" {
  type        = string
  description = "Address prefix for the foundry subnet in CIDR notation. This subnet will host AI Foundry private endpoints."
  default     = "10.0.1.0/24"

  validation {
    condition     = can(cidrhost(var.foundry_subnet_address_prefix, 0))
    error_message = "The foundry_subnet_address_prefix must be a valid CIDR notation."
  }
}

# Agent Subnet Configuration
variable "agent_subnet_address_prefix" {
  type        = string
  description = "Address prefix for the agent subnet in CIDR notation. This subnet will host AI Foundry Agents via subnet injection."
  default     = "10.0.2.0/24"

  validation {
    condition     = can(cidrhost(var.agent_subnet_address_prefix, 0))
    error_message = "The agent_subnet_address_prefix must be a valid CIDR notation."
  }
}

# Network Security Group Configuration
variable "create_network_security_groups" {
  type        = bool
  description = "Whether to create Network Security Groups for the subnets with basic security rules."
  default     = true
}

# Route Table Configuration
variable "create_route_tables" {
  type        = bool
  description = "Whether to create Route Tables for the subnets."
  default     = false
}
