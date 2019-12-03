variable "name_prefix" {
  description = "Azure name prefix"
}

variable "resource_group_name" {
  description = "Resource group"
}

variable "location" {
  description = "Azure location"
  default     = "westeurope"
}

variable "vmsize" {
  description = "VM Size"
  default     = "Standard_D2_v2"
}

variable "vmcount" {
  description = "VM Count"
  default     = "3"
}

variable "subnet_name" {
  description = "Azure subnet name"
}

variable "vnet_name" {
  description = "Azure vnet name"
}

variable "vnet_rg" {
  description = "Azure net resource group"
}