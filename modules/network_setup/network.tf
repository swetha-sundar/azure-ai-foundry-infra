# Creates a VNet with two subnets required for private networking:
# - foundry-subnet: For AI Foundry private endpoints
# - agent-subnet: For AI Foundry Agents injection

# Resource Group for Network Resources (optional - can use existing)
resource "azurerm_resource_group" "network" {
  count    = var.create_network_resource_group ? 1 : 0
  name     = var.network_resource_group_name != null ? var.network_resource_group_name : "${var.project_name}-network-rg"
  location = var.location
  tags     = var.tags
}

# Get existing resource group if not creating new one
data "azurerm_resource_group" "network" {
  count = var.create_network_resource_group ? 0 : 1
  name  = var.network_resource_group_name
}

locals {
  network_resource_group_name = var.create_network_resource_group ? azurerm_resource_group.network[0].name : data.azurerm_resource_group.network[0].name
}

# Virtual Network
resource "azurerm_virtual_network" "foundry_vnet" {
  name                = var.vnet_name != null ? var.vnet_name : "${var.project_name}-vnet"
  address_space       = [var.vnet_address_space]
  location            = var.location
  resource_group_name = local.network_resource_group_name
  tags                = var.tags
}

# Foundry Subnet - For AI Foundry private endpoints
resource "azurerm_subnet" "foundry_subnet" {
  name                 = "foundry-subnet"
  resource_group_name  = local.network_resource_group_name
  virtual_network_name = azurerm_virtual_network.foundry_vnet.name
  address_prefixes     = [var.foundry_subnet_address_prefix]

  # Required for Private Endpoints
  private_endpoint_network_policies = "Disabled"
}

# Agent Subnet - For AI Foundry Agents injection
resource "azurerm_subnet" "agent_subnet" {
  name                 = "agent-subnet"
  resource_group_name  = local.network_resource_group_name
  virtual_network_name = azurerm_virtual_network.foundry_vnet.name
  address_prefixes     = [var.agent_subnet_address_prefix]

  # Required for Private Endpoints
  private_endpoint_network_policies = "Disabled"

  # Required delegation for Container Apps (AI Foundry Agents)
  delegation {
    name = "Microsoft.App/environments"
    service_delegation {
      name = "Microsoft.App/environments"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}

# Network Security Group for Foundry Subnet
resource "azurerm_network_security_group" "foundry_nsg" {
  count               = var.create_network_security_groups ? 1 : 0
  name                = "${azurerm_subnet.foundry_subnet.name}-nsg"
  location            = var.location
  resource_group_name = local.network_resource_group_name
  tags                = var.tags

  # Allow HTTPS inbound for private endpoints
  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = var.vnet_address_space
    destination_address_prefix = "*"
  }

  # Allow outbound to internet for Azure services
  security_rule {
    name                       = "AllowInternetOutbound"
    priority                   = 1000
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }
}

# Network Security Group for Agent Subnet
resource "azurerm_network_security_group" "agent_nsg" {
  count               = var.create_network_security_groups ? 1 : 0
  name                = "${azurerm_subnet.agent_subnet.name}-nsg"
  location            = var.location
  resource_group_name = local.network_resource_group_name
  tags                = var.tags

  # Allow HTTPS inbound within VNet
  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = var.vnet_address_space
    destination_address_prefix = "*"
  }

  # Allow Container Apps communication
  security_rule {
    name                       = "AllowContainerApps"
    priority                   = 1100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.agent_subnet_address_prefix
    destination_address_prefix = var.agent_subnet_address_prefix
  }

  # Allow outbound to internet for Azure services
  security_rule {
    name                       = "AllowInternetOutbound"
    priority                   = 1000
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }
}

# Associate NSG with Foundry Subnet
resource "azurerm_subnet_network_security_group_association" "foundry_nsg_association" {
  count                     = var.create_network_security_groups ? 1 : 0
  subnet_id                 = azurerm_subnet.foundry_subnet.id
  network_security_group_id = azurerm_network_security_group.foundry_nsg[0].id
}

# Associate NSG with Agent Subnet
resource "azurerm_subnet_network_security_group_association" "agent_nsg_association" {
  count                     = var.create_network_security_groups ? 1 : 0
  subnet_id                 = azurerm_subnet.agent_subnet.id
  network_security_group_id = azurerm_network_security_group.agent_nsg[0].id
}

# Route Table for Foundry Subnet (optional)
resource "azurerm_route_table" "foundry_rt" {
  count                         = var.create_route_tables ? 1 : 0
  name                          = "${azurerm_subnet.foundry_subnet.name}-rt"
  location                      = var.location
  resource_group_name           = local.network_resource_group_name
  bgp_route_propagation_enabled = true
  tags                          = var.tags
}

# Route Table for Agent Subnet (optional)
resource "azurerm_route_table" "agent_rt" {
  count                         = var.create_route_tables ? 1 : 0
  name                          = "${azurerm_subnet.agent_subnet.name}-rt"
  location                      = var.location
  resource_group_name           = local.network_resource_group_name
  bgp_route_propagation_enabled = true
  tags                          = var.tags
}

# Associate Route Table with Foundry Subnet
resource "azurerm_subnet_route_table_association" "foundry_rt_association" {
  count          = var.create_route_tables ? 1 : 0
  subnet_id      = azurerm_subnet.foundry_subnet.id
  route_table_id = azurerm_route_table.foundry_rt[0].id
}

# Associate Route Table with Agent Subnet
resource "azurerm_subnet_route_table_association" "agent_rt_association" {
  count          = var.create_route_tables ? 1 : 0
  subnet_id      = azurerm_subnet.agent_subnet.id
  route_table_id = azurerm_route_table.agent_rt[0].id
}
