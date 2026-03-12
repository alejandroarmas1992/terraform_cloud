############################
# 1. DATA SOURCE & VNET
############################

data "azurerm_resource_group" "info" {
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.prefix}"
  location            = data.azurerm_resource_group.info.location
  resource_group_name = data.azurerm_resource_group.info.name
  address_space       = ["10.70.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "snet-${var.prefix}"
  resource_group_name  = data.azurerm_resource_group.info.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.70.1.0/24"]
}

resource "azurerm_container_registry" "acr" {
  name                = "acr${var.prefix}"
  resource_group_name = data.azurerm_resource_group.info.name
  location            = data.azurerm_resource_group.info.location
  sku                 = "Standard"
  admin_enabled       = false
}
# PERMISOS ACR -> AKS (Añadir esto)
############################
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

############################
# 2. AKS (Simplificado)
############################

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.prefix}-dev"
  location            = data.azurerm_resource_group.info.location
  resource_group_name = data.azurerm_resource_group.info.name
  dns_prefix          = "${var.prefix}-dns"

  default_node_pool {
    name           = "systempool"
    vm_size        = var.vm_size
    node_count     = var.node_count
    vnet_subnet_id = azurerm_subnet.subnet.id
    # Borra la línea enable_auto_scaling = false
    # Si quisieras activarlo, sería:
    # enable_auto_scaling = true
    # min_count           = 1
    # max_count           = 1
  }

  identity { type = "SystemAssigned" }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    service_cidr      = "10.100.100.0/24"
    dns_service_ip    = "10.100.100.10"
  }

  # Permiso automático para que AKS pueda jalar imágenes del ACR
  role_based_access_control_enabled = true
}

# Node Pool adicional simplificado
resource "azurerm_kubernetes_cluster_node_pool" "workloads" {
  name                  = "poolapps"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.vm_size
  node_count            = 1
  vnet_subnet_id        = azurerm_subnet.subnet.id # Dinámico, sin IDs largos manuales
}

############################
# 3. HELM - Ingress Nginx
############################

resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  version          = "4.10.0"

  timeout         = 900
  wait            = true
  cleanup_on_fail = true

  values = [
    yamlencode({
      controller = {
        replicaCount = 1
        service = {
          annotations = {
            "service.beta.kubernetes.io/azure-load-balancer-internal"        = "true"
            "service.beta.kubernetes.io/azure-load-balancer-internal-subnet" = "snet-aksjm"
          }
        }
      }
    })
  ]
} # <--- ESTA ES LA LLAVE QUE PROBABLEMENTE FALTABA
