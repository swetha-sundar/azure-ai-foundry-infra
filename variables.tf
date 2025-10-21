
variable "location" {
  type        = string
  description = "Azure region where the resource should be deployed."
  default     = "eastus"
  nullable    = false
}

variable "resource_group_resource_id" {
  type        = string
  description = "The resource group resource id where the module resources will be deployed. If not provided, a new resource group will be created."
  default     = null
}

variable "project_name" {
  type        = string
  description = "The name of the AI Foundry project"
  default     = "default-project"
}

variable "project_display_name" {
  type        = string
  description = "The display name of the AI Foundry project"
  default     = "Default Project"
}

variable "project_description" {
  type        = string
  description = "The description of the AI Foundry project"
  default     = "Default Project description"
}

variable "sku" {
  type        = string
  description = "The SKU for the AI Foundry resource. The default is 'S0'."
  default     = "S0"
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see https://aka.ms/avm/telemetryinfo.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags to be applied to all resources."
}

variable "agents_subnet_id" {
  type        = string
  description = "The subnet ID where AI Foundry Agents will be injected."
}

variable "foundry_subnet_id" {
  description = "The subnet ID for the AI Foundry private endpoints."
  type        = string
}

variable "existing_capability_host_resource_group_id" {
  type        = string
  description = "Resource group ID that contains the existing capability host resources (Cosmos DB, Storage, AI Search)."
}

variable "existing_cosmosdb_account_name" {
  type        = string
  description = "Existing Cosmos DB account name to use for agent thread and entity stores."
}

variable "existing_storage_account_name" {
  type        = string
  description = "Existing Storage Account name to use for agent storage."
}

variable "existing_search_service_name" {
  type        = string
  description = "Existing Azure AI Search service name to use as vector store."
}

variable "monitor_private_link_scope_resource_id" {
  description = "The resource ID of the Monitor Private Link Scope to link Application Insights to."
  type        = string
  default     = null
}
