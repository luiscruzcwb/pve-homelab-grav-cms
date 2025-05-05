#!/bin/bash
echo "===================================="
echo "Aplicando playbook Ansible para Grav (NATIVO)..."
echo "===================================="

ansible-playbook -i ansible/inventory.ini \
  --extra-vars "ansible_password=$ANSIBLE_PASSWORD pm_api_token_id=$PM_API_TOKEN_ID pm_api_token_secret=$PM_API_TOKEN_SECRET pm_api_url=$PM_API_URL" \
  ansible/playbook.yml
