###############
#   VNET AKS  #
###############
resource "azurerm_virtual_network" "vnet_aks" {
  name                = "demo-aks-${var.lab_id}-${var.enviroment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  address_space = ["10.52.0.0/16"]

  tags = {
    project     = "demo-aks"
    environment = var.enviroment
    lab_id      = var.lab_id
  }
}

###########################
#   SUBNET 1 (10.52.1.0)  #
###########################
resource "azurerm_subnet" "subnet_aks" {
  name                 = "demo-aks-${var.lab_id}-snet-ingress"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_aks.name

  address_prefixes = ["10.52.1.0/24"]
}

###########################
#   SUBNET 2 (10.52.2.0)  #
###########################
resource "azurerm_subnet" "subnet_extra" {
  name                 = "demo-aks-${var.lab_id}-snet-aks"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_aks.name

  address_prefixes = ["10.52.2.0/24"]
}