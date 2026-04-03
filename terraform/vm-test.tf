resource "proxmox_virtual_environment_vm" "vm_test" {
  node_name = "pve"
  vm_id     = 200
  name      = "terraform-test"

  clone {
    vm_id = 100
    full  = true
  }

  cpu {
    cores = 2
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 1024
  }

  network_device {
    bridge = "vmbr1"
  }

  started = true
}