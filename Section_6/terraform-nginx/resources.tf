resource "azurerm_virtual_network" "main" {
  name                = "Terraform-network"
  address_space       = ["10.0.0.0/16"]
  location            = "East US"
  resource_group_name = "Devops"
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = "Devops"
  virtual_network_name = "${azurerm_virtual_network.main.name}"
  address_prefix       = "10.0.2.0/24"
}
resource "azurerm_public_ip" "nginx-ip" {
  name                         = "nginx-ip"
  location                     = "East US"
  resource_group_name          = "Devops"
  public_ip_address_allocation = "static"
}
resource "azurerm_network_interface" "main" {
  name                = "Terraform-nic"
  location            = "East US"
  resource_group_name = "Devops"

ip_configuration {
       name                          = "DevopsTerraformIP"
        subnet_id                     = "${azurerm_subnet.internal.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${azurerm_public_ip.nginx-ip.id}"
    }
}

resource "azurerm_virtual_machine" "nginx" {
  name                  = "nginx"
  location              = "East US"
  resource_group_name   = "Devops"
  network_interface_ids = ["${azurerm_network_interface.main.id}"]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "DevOps"
    admin_username = "Videos"
    admin_password = "Terminate@123"
  }  


  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags {
    environment = "staging"
  }
}  