output "vm_ips" {
  description = "IPs asignadas a cada VM de la infraestructura"
  value = {
    wireguard   = "192.168.100.11"
    nginx       = "192.168.100.12"
    nextcloud   = "192.168.100.13"
    vaultwarden = "192.168.100.14"
    ansible     = "192.168.100.20"
  }
}