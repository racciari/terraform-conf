#!/bin/bash
set -xe

source secret.tfvars
export access_key secret_key PROJECT_ID zone REGION

# Get project ID
curl -s -H "X-Auth-Token: $secret_key" https://account.scaleway.com/tokens/$access_key \
  | jq -r '.token.project_id'

# List security groups
#curl -s -H "X-Auth-Token: $secret_key" https://api.scaleway.com/instance/v1/zones/$zone/security_groups | jq
# List IPs
#curl -s -H "X-Auth-Token: $secret_key" https://api.scaleway.com/instance/v1/zones/$zone/ips | jq
# List Servers
#curl -s -H "X-Auth-Token: $secret_key" https://api.scaleway.com/instance/v1/zones/$zone/servers| jq
