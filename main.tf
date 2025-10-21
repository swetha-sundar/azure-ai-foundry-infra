############################################################
#
# Provisions an Azure AI Foundry environment configured for
# private networking. Foundry disables public access and
# injects the Agents capability into an existing subnet.
# Uses existing resources for agent capability host.
############################################################

module "common_models" {
  source = "./modules/common_models"
}

module "naming" {
  source        = "Azure/naming/azurerm"
  version       = "0.4.2"
  suffix        = [local.base_name]
  unique-length = 5
}

resource "azurerm_resource_group" "this" {
  count    = var.resource_group_resource_id == null ? 1 : 0
  location = var.location
  name     = module.naming.resource_group.name_unique
  tags     = var.tags
}

locals {
  base_name                  = "finanalyst-private"
  resource_group_resource_id = var.resource_group_resource_id != null ? var.resource_group_resource_id : azurerm_resource_group.this[0].id
  resource_group_name        = var.resource_group_resource_id != null ? provider::azapi::parse_resource_id("Microsoft.Resources/resourceGroups", var.resource_group_resource_id).resource_group_name : azurerm_resource_group.this[0].name
}

# Existing capability host resources (Cosmos DB, Storage, AI Search)
module "capability_host_resources" {
  source = "./modules/agent_capability_host_connections"

  location                   = var.location
  resource_group_resource_id = var.existing_capability_host_resource_group_id

  cosmosdb_account_name = var.existing_cosmosdb_account_name
  storage_account_name  = var.existing_storage_account_name
  search_service_name   = var.existing_search_service_name
}

# Core AI Foundry environment with private networking enabled
module "ai_foundry" {
  source = "./modules/ai_foundry"

  resource_group_id = local.resource_group_resource_id
  location          = var.location
  sku               = var.sku
  ai_foundry_name   = module.naming.cognitive_account.name_unique

  project_name         = var.project_name
  project_description  = var.project_description
  project_display_name = var.project_display_name

  model_deployments = [
    module.common_models.gpt_4_1,
    module.common_models.o4_mini,
    module.common_models.text_embedding_3_large
  ]

  application_insights = {
    resource_id       = module.application_insights.resource_id
    name              = module.application_insights.name
    connection_string = module.application_insights.connection_string
  }

  agent_capability_host_connections = module.capability_host_resources.connections

  # Private networking
  agents_subnet_id  = var.agents_subnet_id
  foundry_subnet_id = var.foundry_subnet_id

  tags = var.tags
}
