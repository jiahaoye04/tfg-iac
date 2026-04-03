resource "proxmox_virtual_environment_vm" "ansible" {
  node_name = "pve"
  vm_id     = 120
  name      = "ansible-control"

  clone {
    vm_id = 100
    full  = true
  }

  agent { 
    enabled = false 
  }

  cpu {
    cores = 2
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 2048
  }

  network_device {
    bridge = "vmbr1"
  }

  started = true
}