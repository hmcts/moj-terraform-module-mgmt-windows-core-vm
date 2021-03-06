# Here is the code which actually creates a resources using the module

resource "random_string" "password" {
  length  = 20
  special = true
}

module "vm-test-tf-mgmtwinvm" {
  source                      = "../module"
  vm_name                     = "vm-test-win"
  resource_group              = "${azurerm_resource_group.test.name}"
  subnet_id                   = "${azurerm_subnet.test.id}"
  avset_id                    = "${azurerm_availability_set.test.id}"
  storage_account             = "${azurerm_storage_account.test.name}"
  diagnostics_storage_account = "${azurerm_storage_account.test.name}"
  location                    = "${var.azure_region}"
  vm_size                     = "Standard_B1ms"                        # Use lower specs to save money
  instance_count              = 1
  product                     = "mgmt"
  env                         = "sandbox"
  role                        = "testbox"
  admin_username              = "vmadmin"
  admin_password              = "${random_string.password.result}"
}
