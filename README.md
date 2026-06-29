# tfg-iac — Infraestructura de virtualización automatizada mediante IaC

![Proxmox VE](https://img.shields.io/badge/Proxmox%20VE-9.1-E57000?logo=proxmox&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-bpg%2Fproxmox-7B42BC?logo=terraform&logoColor=white)
![Ansible](https://img.shields.io/badge/Ansible-2.10-EE0000?logo=ansible&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker&logoColor=white)
![WireGuard](https://img.shields.io/badge/WireGuard-VPN-88171A?logo=wireguard&logoColor=white)
![Nginx](https://img.shields.io/badge/Nginx-TLS-009639?logo=nginx&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-blue)

> Trabajo Final de Grado — Ingeniería Informática, mención Tecnologías de la Información
> (Escola d'Enginyeria, UAB). Diseño e implementación de una infraestructura de virtualización
> autoalojada y **totalmente automatizada** mediante *Infrastructure as Code*.

## Descripción

Este repositorio contiene todo el código que define y configura una infraestructura completa
sobre un servidor propio en modo *bare-metal*. **Proxmox VE** actúa como hipervisor;
**Terraform** aprovisiona las máquinas virtuales y **Ansible** las configura de forma
idempotente. El resultado es un conjunto de servicios reales (Nextcloud, Vaultwarden, Homer)
accesibles **únicamente a través de una VPN**, reproducible y reconstruible desde cero a partir
del código.

El principio rector es que **la infraestructura es desechable y el código es la única fuente de
verdad**: cualquier máquina puede destruirse y recrearse íntegramente con `terraform apply` +
`ansible-playbook`.

## Arquitectura

```
Cliente (navegador / app)
   │  HTTPS 443  (solo a través de la VPN WireGuard)
   ▼
Nginx — proxy inverso + terminación TLS (Let's Encrypt, DuckDNS)
   │  HTTP interno (red aislada 192.168.100.0/24)
   ▼
Servicios en Docker:  Nextcloud · Vaultwarden · Homer
                      └── PostgreSQL (VM dedicada, instalación nativa)
```

- **Hipervisor:** Proxmox VE 9.1 (*bare-metal*).
- **Aprovisionamiento:** Terraform con el *provider* `bpg/proxmox` (módulo de VM reutilizable).
- **Configuración:** Ansible, un rol por servicio, todos idempotentes.
- **Red:** puente externo `vmbr0` y puente interno aislado `vmbr1` (`192.168.100.0/24`); acceso
  remoto por túnel WireGuard (`10.0.0.0/24`, *split tunneling*).
- **Publicación:** Nginx con TLS válido (Let's Encrypt vía *challenge* DNS-01) y dominio DuckDNS.

## Stack tecnológico

| Capa | Tecnología |
| --- | --- |
| Hipervisor | Proxmox VE 9.1 |
| Infrastructure as Code | Terraform (`bpg/proxmox`) · Ansible 2.10 |
| Contenedores | Docker · Docker Compose |
| Servicios | Nextcloud · Vaultwarden · Homer · PostgreSQL 14 |
| Red y seguridad | WireGuard · Nginx · Let's Encrypt · DuckDNS · UFW |
| Control de versiones | Git |

Todo el *stack* es software de código abierto.

## Estructura del repositorio

```
tfg-iac/
├── terraform/                      # Aprovisionamiento  (PC personal)
│   ├── main.tf  variables.tf  providers.tf
│   └── modules/vm/                 # Módulo reutilizable (clone + disco condicional)
│       └── main.tf  variables.tf  outputs.tf
└── ansible/                        # Configuración      (VM 120, nodo de control)
    ├── ansible.cfg  site.yml       # Punto de entrada: un rol por grupo de hosts
    ├── inventario/hosts.ini
    └── roles/
        ├── base/  disk_resize/  nginx/  homer/  wireguard/
        └── postgresql/  postgresql_backup/  nextcloud/  vaultwarden/
```

El repositorio se edita desde dos puestos: **Terraform** desde el PC personal y **Ansible**
desde la VM de control (nodo 120).

## Requisitos previos

- Nodo **Proxmox VE 9.1** operativo con una **plantilla base** (VM 100, Ubuntu Server +
  cloud-init + QEMU Guest Agent).
- **Terraform** en el PC y un **token de API** de Proxmox.
- **Nodo de control Ansible** (VM 120) con **Ansible 2.10**.
- **Cliente WireGuard** para el acceso a la infraestructura.

## Despliegue

### 1. Aprovisionar la VM (Terraform, desde el PC)

```bash
cd terraform
terraform init        # solo la primera vez
terraform plan
terraform apply
```

Añadir un servicio consiste en replicar un bloque `module "..." { source = "./modules/vm" ... }`
con sus parámetros.

### 2. Preparar la VM clonada (consola web de Proxmox)

> Realiza este paso desde la **consola web de Proxmox**, nunca por SSH hacia la IP que vas a
> cambiar (te autodesconectarías).

```bash
sudo sed -i 's#192.168.100.10/24#192.168.100.XX/24#' /etc/netplan/50-cloud-init.yaml
echo "network: {config: disabled}" | sudo tee /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
sudo netplan apply
```

El segundo comando es imprescindible: sin él, cloud-init reescribe la IP en el siguiente reinicio.

### 3. Habilitar la gestión por Ansible (desde la VM 120)

```bash
ssh-copy-id jiahao@192.168.100.XX      # SSH sin contraseña
# dentro de la VM, sudo sin contraseña con visudo:
#   jiahao ALL=(ALL) NOPASSWD: ALL
ansible <grupo> -m shell -a "whoami" --become   # debe devolver: root
```

### 4. Configurar (Ansible, desde `ansible/`)

```bash
cd ansible
ansible-playbook site.yml --limit <grupo>
```

Grupos disponibles: `nginx`, `nextcloud`, `postgresql`, `vaultwarden`, `homer`, `wireguard`.

## Servicios desplegados

| Servicio | Función | Acceso |
| --- | --- | --- |
| **Homer** | Panel que reúne los accesos a todos los servicios | Raíz del dominio |
| **Nextcloud** | Almacenamiento y sincronización de archivos | `/nextcloud` |
| **Vaultwarden** | Gestor de contraseñas compatible con Bitwarden | `/vaultwarden` |
| **PostgreSQL** | Base de datos de los servicios (VM dedicada) | Interno |
| **WireGuard** | VPN; único punto de entrada a la infraestructura | UDP 51820 |
| **Nginx** | Proxy inverso + TLS | HTTPS 443 |

## Seguridad

- Acceso a los servicios **exclusivamente a través de la VPN** WireGuard.
- *Rate limiting* y cabeceras de seguridad en Nginx; restricción por rango de IP en rutas sensibles.
- TLS extremo a extremo (Let's Encrypt) y cortafuegos UFW con política de entrada restrictiva.

## Copias de seguridad

Dos capas automáticas y encadenadas: `pg_dumpall` (02:30) vuelca la base de datos y `vzdump`
(03:00) respalda las VMs con estado, de modo que el volcado SQL viaja dentro de la copia de la VM
(retención de 7 copias en el *pool* ZFS). La restauración se valida de forma no destructiva sobre
un identificador de VM temporal.

## Resiliencia eléctrica (sistema «canario»)

El servidor y el router están protegidos por un SAI; dos placas **ESP32** alimentadas de la red
emiten una señal periódica. Si dejan de emitir (corte de luz), el host detecta el silencio y
ejecuta un apagado limpio antes de agotar la batería del SAI, enviando además un aviso por *push*.

> El **firmware del ESP32** y los componentes que viven en el nodo Proxmox (`canary.sh`,
> `canary.service`, `/etc/network/interfaces`) se ejecutan **fuera** del flujo Terraform/Ansible
> y, por tanto, **no forman parte de este repositorio**; su código figura en el documento *Código
> fuente* del dossier del TFG.

## Qué no está versionado aquí

- Estado y secretos de Terraform (`.tfstate`, `.tfvars`) y claves privadas — excluidos vía `.gitignore`.
- Configuración de `vzdump`, que reside en el hipervisor (`/etc/pve/jobs.cfg`).
- Código del *host*/ESP32 (ver sección anterior).
- Valores sensibles (IP pública, *topic* de ntfy, contraseñas), censurados en toda la documentación.

## Documentación

La documentación completa (memoria del TFG, manual de usuario e instalación, estudio de viabilidad
y código fuente comentado) se recoge en el dossier del proyecto.

## Licencia

Distribuido bajo licencia **MIT**. Consulta el fichero [`LICENSE`](LICENSE) para más detalles.

## Autor

**Jiahao Ye** — jiahao.ye2@autonoma.cat
Tutor: Hing Fai Kevin Chow · Escola d'Enginyeria, Universitat Autònoma de Barcelona · Curso 2025–2026
