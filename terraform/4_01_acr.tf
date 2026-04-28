resource "azurerm_container_registry" "acr" {
  name                = "demoacr${var.lab_id}${var.enviroment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku           = "Basic"
  admin_enabled = true

  tags = {
    project     = "demo-aks"
    environment = var.enviroment
    lab_id      = var.lab_id
  }
}
