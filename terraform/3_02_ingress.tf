resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  timeout = 600
  wait    = true

  values = [
    yamlencode({
      controller = {
        nodeSelector = {
          agentpool = "systempool"
        }

        service = {
          type = "LoadBalancer"

          annotations = {
            "service.beta.kubernetes.io/azure-load-balancer-internal"                  = "true"
            "service.beta.kubernetes.io/azure-load-balancer-internal-subnet"           = azurerm_subnet.subnet_aks.name
            "service.beta.kubernetes.io/azure-load-balancer-health-probe-request-path" = "/healthz"
          }
        }
      }
    })
  ]

  depends_on = [
    azurerm_kubernetes_cluster.aks,
    azurerm_role_assignment.aks_network_contributor
  ]
}
