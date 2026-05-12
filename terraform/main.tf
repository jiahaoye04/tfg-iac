terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.73"
    }
  }
}

provider "proxmox" {
  endpoint  = "https://192.168.100.1:8006/api2/json"
  api_token = var.proxmox_api_token
  insecure  = true
}

module "nextcloud" {
  source         = "./modules/vm"
  vm_id          = 103
  name           = "nextcloud"
  cores          = 2
  memory         = 4096
  proxmox_node   = var.proxmox_node
  template_vm_id = var.template_vm_id
  network_bridge = var.network_bridge
  cpu_type       = var.cpu_type
}

module "vaultwarden" {
  source         = "./modules/vm"
  vm_id          = 104
  name           = "vaultwarden"
  cores          = 1
  memory         = 2048
  proxmox_node   = var.proxmox_node
  template_vm_id = var.template_vm_id
  network_bridge = var.network_bridge
  cpu_type       = var.cpu_type
}

module "postgresql" {
  source         = "./modules/vm"
  vm_id          = 105
  name           = "postgresql"
  cores          = 1
  memory         = 2048
  proxmox_node   = var.proxmox_node
  template_vm_id = var.template_vm_id
  network_bridge = var.network_bridge
  cpu_type       = var.cpu_type
}