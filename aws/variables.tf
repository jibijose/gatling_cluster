
variable "location" {
  description = "Aws location"
  default     = "eu-west-1"
}

variable "vpc_cidr" {
  description = "Aws vpc cidr"
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "Aws subnet cidr"
  default     = "10.0.2.0/24"
}

variable "vmsize" {
  description = "Aws VM Size"
  default     = "c4.xlarge"
}

variable "vmcount" {
  description = "VMs Count"
  default     = "3"
}

variable "my_public_ip" {
  description = "Public Ip"
}

variable "simulationclass" {
  description = "Simulation"
}