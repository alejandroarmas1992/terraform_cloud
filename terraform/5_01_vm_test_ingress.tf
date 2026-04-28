############################################
# VM de pruebas en la subnet del Ingress
############################################

############################################
# IP pública para acceso SSH
############################################
resource "azurerm_public_ip" "vm_test_ingress_pip" {
  name                = "pip-vm-test-ingress-${var.lab_id}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"

  tags = {
    purpose     = "ingress-test"
    environment = var.enviroment
    lab_id      = var.lab_id
  }
}

############################################
# NIC de la VM (subnet del ingress)
############################################
resource "azurerm_network_interface" "vm_test_ingress_nic" {
  name                = "nic-vm-test-ingress-${var.lab_id}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_aks.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_test_ingress_pip.id
  }

  # Garantiza que el Public IP exista antes
  depends_on = [
    azurerm_public_ip.vm_test_ingress_pip
  ]

  tags = {
    purpose     = "ingress-test"
    environment = var.enviroment
    lab_id      = var.lab_id
  }
}

############################################
# VM Linux mínima
############################################
resource "azurerm_linux_virtual_machine" "vm_test_ingress" {
  name                = "vm-test-ingress-${var.lab_id}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = "Standard_B1s"
  admin_username      = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.vm_test_ingress_nic.id
  ]

  # Garantiza que la NIC exista antes de la VM
  depends_on = [
    azurerm_network_interface.vm_test_ingress_nic
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = {
    purpose     = "ingress-test"
    environment = var.enviroment
    lab_id      = var.lab_id
  }
}