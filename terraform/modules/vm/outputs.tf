output "vm_id" {
  description = "ID de la VM creada"
  value       = proxmox_virtual_environment_vm.vm.vm_id
}

output "vm_name" {
  description = "Nombre de la VM creada"
  value       = proxmox_virtual_environment_vm.vm.name
}