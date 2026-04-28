# Creación grupo de recursos
resource "azurerm_resource_group" "rg" {
  name     = "rg-demo-aks-${var.lab_id}-${var.enviroment}"
  location = var.location

  tags = {
    project     = "demo-aks"
    environment = var.enviroment
    lab_id      = var.lab_id
  }


}

