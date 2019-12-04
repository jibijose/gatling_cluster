provider "azurerm" {
  version = ">=1.36.0"
}

data "azurerm_subnet" "test_subnet" {
  name                 = "${var.subnet_name}"
  virtual_network_name = "${var.vnet_name}"
  resource_group_name  = "${var.vnet_rg}"
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "null_resource" "save-key" {
  provisioner "local-exec" {
    command = <<EOF
      echo "Copying ssh keys into ${path.cwd}/ssh_keys"
      mkdir -p ${path.cwd}/ssh_keys
      echo "${tls_private_key.key.private_key_pem}" > ${path.cwd}/ssh_keys/id_rsa
      echo "${tls_private_key.key.public_key_openssh}" > ${path.cwd}/ssh_keys/id_rsa.pub
      chmod 0600 ${path.cwd}/ssh_keys/id_rsa
      chmod 0600 ${path.cwd}/ssh_keys/id_rsa.pub
EOF
  }
}

resource "azurerm_network_interface" "nic" {
  count                 = "${var.vmcount}"
  name                      = "${var.name_prefix}-${count.index}-vm-nic"
  location                  = "${var.location}"
  resource_group_name       = "${var.resource_group_name}"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = "${data.azurerm_subnet.test_subnet.id}"
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment =  "gatling_test"
    Name = "gatling-cluster-${count.index}-vm-nic"
  }
}

resource "azurerm_virtual_machine" "vm" {
  count                 = "${var.vmcount}"
  name                  = "${var.name_prefix}-${count.index}-vm"
  location              = "${var.location}"
  resource_group_name   = "${var.resource_group_name}"
  network_interface_ids = ["${element(azurerm_network_interface.nic.*.id, count.index)}"]
  vm_size               = "${var.vmsize}"
  delete_data_disks_on_termination = true
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.name_prefix}-${count.index}-vm-osdisk"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = "${var.name_prefix}-${count.index}-vm"
    admin_username = "ubuntu"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/ubuntu/.ssh/authorized_keys"
      key_data = "${trimspace(tls_private_key.key.public_key_openssh)} ubuntu@azure.com"
    }
  }

  provisioner "remote-exec" {
    connection {
      type = "ssh"
      host = "${element(azurerm_network_interface.nic.*.private_ip_address, count.index)}"
      user     = "ubuntu"
      private_key = "${trimspace(tls_private_key.key.private_key_pem)}"
    }

    inline = [
      "sudo apt update -qqqq",
      "sudo apt install openjdk-8-jdk --yes -qqqq",
      "sudo apt install unzip --yes -qqqq"
    ]
  }

  tags = {
    environment = "gatling_test"
    Name = "gatling-cluster-${count.index}-vm"
  }
}