data "template_file" "server_name" {
  template = "$${prefix}${format("%02d", count.index + 1)}"
  count    = "${var.instance_count}"

  vars {
    prefix = "${var.vm_name}"
  }
}

# Create Networking
resource "azurerm_network_interface" "reform-nonprod" {
  count               = "${var.instance_count}"
  name                = "${element(data.template_file.server_name.*.rendered, count.index)}-NIC"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group}"

  ip_configuration {
    name                          = "${element(data.template_file.server_name.*.rendered, count.index)}-NIC"
    subnet_id                     = "/subscriptions/${var.azure_subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Network/virtualNetworks/${var.vnet}/subnets/${var.subnet}"
    private_ip_address_allocation = "dynamic"
  }
}

# Create Virtual Machine
resource "azurerm_virtual_machine" "reform-nonprod" {
  count                            = "${var.instance_count}"
  name                             = "${element(data.template_file.server_name.*.rendered, count.index)}"
  location                         = "${var.location}"
  resource_group_name              = "${var.resource_group}"
  network_interface_ids            = ["${element(azurerm_network_interface.reform-nonprod.*.id, count.index)}"]
  vm_size                          = "${var.vm_size}"
  delete_os_disk_on_termination    = "${var.delete_os_disk_on_termination}"
  delete_data_disks_on_termination = "${var.delete_data_disks_on_termination}"

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter-Server-Core"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${element(data.template_file.server_name.*.rendered, count.index)}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  # Data disk
  storage_data_disk {
    name              = "data"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "120"
  }

  os_profile {
    computer_name  = "${var.vm_name}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }

  os_profile_windows_config {
    enable_automatic_upgrades = true
    provision_vm_agent = true
  }

  tags {
    type      = "vm"
    product   = "${var.product}"
    env       = "${var.env}"
    tier      = "${var.tier}"
    ansible   = "${var.ansible}"
    terraform = "true"
    role      = "${var.role}"
  }
}

# Run Script Extension
resource "azurerm_virtual_machine_extension" "reform-nonprod" {
  name                 = "${element(data.template_file.server_name.*.rendered, count.index)}"
  location             = "${var.location}"
  resource_group_name  = "${var.resource_group}"
  virtual_machine_name = "${azurerm_virtual_machine.reform-nonprod.name}"
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "1.8"

  settings = <<SETTINGS
     {
       "commandToExecute": "${var.extension_command}"
     }
SETTINGS
}
