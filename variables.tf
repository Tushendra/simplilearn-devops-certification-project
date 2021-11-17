variable "vm-name" {
    description = "virtual machine name"
    type = string
    default = "simplilearn-devops-project-vm"

}
variable "location" {
    description = "location for vm"
    type = string
    default = "East Us"
  
}
variable "computername" {
    description = "computer name defined"
    type = string
    default = "tushvm1"
  
}

variable "vmpassword" {
    description = "password of created vm"
    type = string
    default = "MishraTush@2021"
  
}

variable "public-ip" {
    description = "azure public ip name"
    type = string
    default = "tushpublicip"
}