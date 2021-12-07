#!/usr/bin/env bash

set -euo pipefail

source ./outputs.sh "${1}"

ANSIBLE_INVENTORY="####
# Ansible Hosts File for HPE Container Platform Deployment
# created by Dirk Derichsweiler
# modified by Erdinc Kaya
#
# Important:
# use only ip addresses in this file
####
[controllers]
$(echo ${CTRL_PRV_IPS[@]} | sed 's/ /\n/g')
[gateway]
$(echo ${GATW_PRV_IPS[@]} | sed 's/ /\n/g')
[workers]
$(echo ${WRKR_PRV_IPS[@]} | sed 's/ /\n/g')
[ad_server]
${AD_PRV_IP}
[mapr]
$(echo ${MAPR_PRV_IPS[@]} | sed 's/ /\n/g')
[all:vars]
ansible_connection=ssh
ansible_user=centos
install_file=${EPIC_FILENAME}
download_url=${EPIC_DL_URL}
admin_password=${ADMIN_PASS}
gateway_pub_dns=${GATW_PUB_DNS[0]}
ssh_prv_key=${SSH_PRV_KEY_PATH}
is_mlops=${IS_MLOPS}
is_mapr=${IS_MAPR}
is_runtime=${IS_RUNTIME}
ad_realm=SAMDOM.EXAMPLE.COM
[mapr:vars]
ansible_user=ubuntu"

echo "${ANSIBLE_INVENTORY}" > ./ansible/inventory.ini

SSH_OPTS="-i generated/controller.prv_key -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ProxyCommand=\"ssh -i generated/controller.prv_key -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -W %h:%p -q centos@${GATW_PUB_IPS[0]}\""
echo "ansible_ssh_common_args: ${SSH_OPTS}" > ./ansible/group_vars/all.yml
echo "ssh ${SSH_OPTS} \$1" > ./generated/ssh_host.sh
chmod +x ./generated/ssh_host.sh

ANSIBLE_CMD="ansible-playbook"
if [ ${IS_VERBOSE} ]; then
  ANSIBLE_CMD="${ANSIBLE_CMD} -v"
fi

${ANSIBLE_CMD} -f 10 \
  -i ./ansible/inventory.ini \
  ./ansible/install.yml | tee "${1}/run.log"

echo "Platform installion complete, gateway should be accessible at https://${GATW_PUB_DNS}/"

# Continue if completed
echo "Stage 3 complete"
# ./04-configure.sh "${1}"

exit 0