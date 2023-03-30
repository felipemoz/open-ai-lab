
variable "resource_group_name" {}
variable "location" {}
variable "vnet_name" {}
variable "vnet_address_space" {}
variable "subnet_name" {}
variable "subnet_address_prefixes" {}
variable "cognitive_account_name" {}
variable "cognitive_account_sku_name" {}
variable "cognitive_account_sku_tier" {}
variable "subscription_id" {}


terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
    subscription_id = var.subscription_id
    features {}
}

resource "azurerm_resource_group" "rm" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.rm.location
  resource_group_name = azurerm_resource_group.rm.name
}

resource "azurerm_subnet" "subnet1" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rm.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_address_prefixes
}

resource "azurerm_cognitive_account" "cogs_account" {
  name                = var.cognitive_account_name
  location            = azurerm_resource_group.rm.location
  resource_group_name = azurerm_resource_group.rm.name
  kind                = "OpenAI"
  sku_name            = var.cognitive_account_sku_name
  dynamic_throttling_enabled = true
  custom_subdomain_name ="openai-sandbox"

  network_acls { 
    default_action = "Deny"
    virtual_network_rules { subnet_id = azurerm_subnet.subnet1.id }
    }
}