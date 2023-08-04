
data "azurerm_client_config" "current" {}
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}
resource "azurerm_key_vault" "key_vault" {
  name                       = var.name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Backup",
      "Create",
      "Decrypt",
      "Delete",
      "Encrypt",
      "Get",
      "Import",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Sign",
      "UnwrapKey",
      "Update",
      "Verify",
      "WrapKey"
    ]
    secret_permissions = [
      "Backup",
      "Delete",
      "Get",
      "List",
      "Purge",
      "Restore",
      "Recover",
      "Set",
      "List",
    ]
  }
}

resource "azurerm_key_vault_secret" "key_vault_secret" {
  name         = "adminuser"
  value        = random_password.password.result
  key_vault_id = azurerm_key_vault.key_vault.id
}



resource "azurerm_mysql_flexible_server" "example" {
  resource_group_name            = var.resource_group_name
  location                       = var.location
  name                           = var.name
  administrator_login            = var.administrator_login
  administrator_password         = random_password.password.result
  backup_retention_days          = var.backup_retention_days
  create_mode                    = var.create_mode  
  geo_redundant_backup_enabled   = var.geo_redundant_backup_enabled
  sku_name                       = var.sku_name
  version                        = var.mysql_version
  zone                           = var.zone

}
resource "azurerm_mysql_flexible_server_firewall_rule" "firewall_rule" {
  name  = "${var.name}-firewallrule"
  resource_group_name = var.resource_group_name
  server_name = var.name
  start_ip_address = "0.0.0.0"
  end_ip_address  = "0.0.0.0"
    
    depends_on = [ azurerm_mysql_flexible_server.example ]
}