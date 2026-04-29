variable "vm_id" {
  description = "ID de la VM en Proxmox"
  type        = number
}

variable "name" {
  description = "Nombre de la VM"
  type        = string
}

variable "cores" {
  description = "Número de cores de CPU"
  type        = number
  default     = 1
}

variable "memory" {
  description = "Memoria RAM en MB"
  type        = number
  default     = 2048
}

variable "proxmox_node" {
  description = "Nombre del nodo de Proxmox"
  type        = string
}

variable "template_vm_id" {
  description = "ID de la VM base para clonar"
  type        = number
}

variable "network_bridge" {
  description = "Bridge de red"
  type        = string
}

variable "cpu_type" {
  description = "Tipo de CPU"
  type        = string
}