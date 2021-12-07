#!/usr/bin/env bash

set -euo pipefail

pushd "${1}" > /dev/null
  TF_IN_AUTOMATION=1 terraform destroy \
    -no-color \
    -parallelism 12 \
    -var-file=<(cat ./*.tfvars) \
    -auto-approve=true \
    # -var="client_cidr_block=$(curl -s http://ipinfo.io/ip)/32"
    
popd > /dev/null

rm -f generated/output.json
rm -f generated/ssh_host.sh
rm -f ansible/group_vars/all.yml
rm -f ansible/inventory.ini
rm -f "${1}/run.log"
## Clean user environment
rm -f ~/.hpecp.conf
rm -f ~/.kube/hpecp_admin.config
rm -f ~/.hpecp_tenant.config

echo "SSH key-pair, certificates and cloud-init files are not removed!"

exit 0