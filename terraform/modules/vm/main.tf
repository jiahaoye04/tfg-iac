terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.73"
    }
  }
}

resource "proxmox_virtual_environment_vm" "vm" {
  node_name = var.proxmox_node
  vm_id     = var.vm_id
  name      = var.name

  clone {
    vm_id = var.template_vm_id
    full  = true
  }

  agent {
    enabled = false
  }

  bios    = "ovmf"
  machine = "q35"

  efi_disk {
    datastore_id = "local-lvm"
    file_format  = "raw"
    type         = "4m"
  }

  cpu {
    cores = var.cores
    type  = var.cpu_type
  }

  memory {
    dedicated = var.memory
  }

  network_device {
    bridge = var.network_bridge
  }

  scsi_hardware = "virtio-scsi-single"

  operating_system {
    type = "l26"
  }

  started = true
}