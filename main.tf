terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = ">= 2.9.11"
    }
    vault = {
      source = "hashicorp/vault"
    }
  }
}

provider "vault" {
  address = "http://192.168.18.170:8200"
  token   = var.vault_token
}

data "vault_kv_secret_v2" "grav" {
  mount = "secret"
  name  = "homelab/grav"
}

locals {
  pm_api_url          = data.vault_kv_secret_v2.grav.data["pm_api_url"]
  pm_api_token_secret = data.vault_kv_secret_v2.grav.data["pm_api_token_secret"]
  pm_api_token_id     = data.vault_kv_secret_v2.grav.data["pm_api_token_id"]
  password            = data.vault_kv_secret_v2.grav.data["password"]
  ssh_password        = data.vault_kv_secret_v2.grav.data["password"]
}

provider "proxmox" {
  pm_api_url          = local.pm_api_url
  pm_api_token_id     = local.pm_api_token_id
  pm_api_token_secret = local.pm_api_token_secret
  pm_tls_insecure     = true
}

resource "proxmox_lxc" "vm-grav" {
  target_node  = var.target_node
  hostname     = var.hostname
  vmid         = var.vmid
  ostemplate   = var.ostemplate
  password     = local.ssh_password
  unprivileged = true
  cores        = 2
  memory       = 2048
  swap         = 1024
  start        = true
  onboot       = true

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = var.vm_ip
    gw     = var.gateway
  }

  rootfs {
    storage = var.storage
    size    = "10G"
  }

  ssh_public_keys = file(var.ssh_key_path)
}


resource "null_resource" "wait_for_ssh" {
  depends_on = [proxmox_lxc.vm-grav]

  provisioner "local-exec" {
    command = <<EOT
      echo '[WAIT] Aguardando SSH da VM Grav...'
      timeout 300 bash -c 'until nc -z 192.168.18.171 22; do sleep 5; done'
    EOT
  }
}

resource "null_resource" "run_ansible_playbook" {
  depends_on = [null_resource.wait_for_ssh]

  provisioner "local-exec" {
    command = "bash ./scripts/run_ansible.sh"
    environment = {
      PM_API_TOKEN_ID     = local.pm_api_token_id
      PM_API_TOKEN_SECRET = local.pm_api_token_secret
      PM_API_URL          = local.pm_api_url
      ANSIBLE_PASSWORD    = local.ssh_password
      VAULT_TOKEN         = var.vault_token
    }
  }
}
