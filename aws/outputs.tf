output "network_interface_private_ip" {
  description = "private ip addresses of the vm nics"
  value       = "${aws_instance.vm.*.public_ip}"
}