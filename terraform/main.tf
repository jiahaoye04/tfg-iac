terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.73"
    }
  }
}

provider "proxmox" {
  endpoint = "https://192.168.100.1:8006/api2/json"
  api_token = var.proxmox_api_token
  insecure  = true
}