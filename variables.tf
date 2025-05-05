variable "target_node" {
  default = "pve"
}

variable "hostname" {
  default = "vm-grav"
}

variable "vmid" {
  default = 115
}

variable "ostemplate" {
  default = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
}

variable "vm_ip" {
  default = "192.168.18.171/24"
}

variable "vm_ip_cidr_only" {
  default = "192.168.18.171"
}

variable "gateway" {
  default = "192.168.18.1"
}

variable "storage" {
  default = "local-lvm"
}

variable "ssh_key_path" {
  description = "Caminho para a chave SSH pública"
  default = "/home/luiscruz/.ssh/id_rsa.pub"
}

variable "vault_token" {
  description = "Token do Vault para acesso aos secrets"
}

