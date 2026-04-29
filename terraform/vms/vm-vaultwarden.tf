resource "proxmox_virtual_environment_vm" "vaultwarden" {
  node_name = var.proxmox_node
  vm_id     = 104
  name      = "vaultwarden"

  clone {
    vm_id = var.template_vm_id
    full  = true
  }

  agent {
    enabled = false
  }

  cpu {
    cores = 1
    type  = var.cpu_type
  }

  memory {
    dedicated = 2048
  }

  network_device {
    bridge = var.network_bridge
  }

  started = true
}