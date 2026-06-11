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
  source              = "./modules/vm"
  vm_id               = 103
  name                = "nextcloud"
  cores               = 2
  memory              = 8192
  disk_size           = 50
  data_disk_size      = 300
  data_disk_datastore = "hdd-data"
  proxmox_node        = var.proxmox_node
  template_vm_id      = var.template_vm_id
  network_bridge      = var.network_bridge
  cpu_type            = var.cpu_type
}

module "vaultwarden" {
  source         = "./modules/vm"
  vm_id          = 104
  name           = "vaultwarden"
  cores          = 1
  memory         = 8192
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
  memory         = 6144
  disk_size      = 64
  proxmox_node   = var.proxmox_node
  template_vm_id = var.template_vm_id
  network_bridge = var.network_bridge
  cpu_type       = var.cpu_type
}

module "homer" {
  source         = "./modules/vm"
  vm_id          = 106
  name           = "homer"
  cores          = 1
  memory         = 4096
  proxmox_node   = var.proxmox_node
  template_vm_id = var.template_vm_id
  network_bridge = var.network_bridge
  cpu_type       = var.cpu_type
}