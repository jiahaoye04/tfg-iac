resource "proxmox_virtual_environment_vm" "nextcloud" {
  node_name = var.proxmox_node
  vm_id     = 103
  name      = "nextcloud"

  clone {
    vm_id = var.template_vm_id
    full  = true
  }

  agent {
    enabled = false
  }

  cpu {
    cores = 2
    type  = var.cpu_type
  }

  memory {
    dedicated = 4096
  }

  network_device {
    bridge = var.network_bridge
  }

  started = true
}