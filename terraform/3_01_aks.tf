###########################################
# AKS Cluster - Laboratorio e02
###########################################

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "demo-aks-${var.lab_id}-${var.enviroment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  dns_prefix         = "aksdns-${var.lab_id}-${var.enviroment}"
  kubernetes_version = "1.33.6"
  sku_tier           = "Free"

  default_node_pool {
    name           = "systempool"
    node_count     = 1
    vm_size        = "Standard_B2s"
    type           = "VirtualMachineScaleSets"
    vnet_subnet_id = azurerm_subnet.subnet_aks.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"

    service_cidr   = "10.100.112.0/24"
    dns_service_ip = "10.100.112.10"

    outbound_type = "loadBalancer"
  }

  role_based_access_control_enabled = true

  tags = {
    environment = var.enviroment
    lab_id      = var.lab_id
    project     = "demo-aks"
  }
}
