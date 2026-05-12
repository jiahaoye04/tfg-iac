variable "proxmox_api_token" {
  description = "Token de API de Proxmox para Terraform"
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  description = "Nombre del nodo de Proxmox"
  type        = string
  default     = "pve"
}

variable "template_vm_id" {
  description = "ID de la VM base (ubuntu-base) para clonar"
  type        = number
  default     = 100
}

variable "network_bridge" {
  description = "Bridge de red interna para las VMs"
  type        = string
  default     = "vmbr1"
}

variable "cpu_type" {
  description = "Tipo de CPU para las VMs"
  type        = string
  default     = "host"
}