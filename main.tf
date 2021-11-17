terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.0" # Optional but recommended in production
    }    
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  
}
# Create Resource Group 
resource "azurerm_resource_group" "TushRG" {
  location = "eastus"
  name = "TushDevproject-RG"  
}

# Create Virtual Machine


resource "azurerm_virtual_network" "main" {
  name                = var.vm-name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.TushRG.location
  resource_group_name = azurerm_resource_group.TushRG.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.TushRG.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "main" {
  name                = "${var.vm-name}-nic"
  location            = azurerm_resource_group.TushRG.location
  resource_group_name = azurerm_resource_group.TushRG.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.public-ip.id
  }
}

resource "azurerm_public_ip" "public-ip" {
  name                = var.public-ip
  resource_group_name = azurerm_resource_group.TushRG.name
  location            = azurerm_resource_group.TushRG.location
  allocation_method   = "Static"

}

resource "azurerm_virtual_machine" "main" {
  name                  = "${var.vm-name}-vm"
  location              = azurerm_resource_group.TushRG.location
  resource_group_name   = azurerm_resource_group.TushRG.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = var.computername
    admin_username = var.computername
    admin_password = var.vmpassword
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "Dev"
  }

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      host     = azurerm_public_ip.public-ip.ip_address
      user     = var.computername
      password = var.vmpassword
    }

    inline = [
    "sudo apt update",
    "sudo apt install -y openjdk-8*",
    "sudo apt-get update",
    "sudo apt-get install -y docker*",
    "sudo apt update",
    "sudo apt install software-properties-common",
    "sudo add-apt-repository ppa:deadsnakes/ppa -y",
    "sudo apt update",
    "sudo apt install -y python3.8",
    "sudo apt-get update",
	   "wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -",
       "echo This is installing 8",
       "sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'",
       "sudo apt-get update",
       "sudo apt-get install jenkins -y",
       "sudo sed -i 's|/bin:/usr/bin:/sbin:/usr/sbin|/bin:/usr/bin:/sbin:/usr/sbin:/home/ubuntu/jdk1.8.0_251/bin|g' /etc/init.d/jenkins",
       "sudo systemctl daemon-reload",
       "sudo systemctl start jenkins",
       "sudo java -version",
       "sudo docker --version",
       "sudo python3 --version",
       "sudo systemctl jenkins status",
    ]
  
    }
}