#!/usr/bin/env bash

set -euo pipefail

source ./outputs.sh "${1}"

ANSIBLE_CMD="ansible-playbook"
if [ ${IS_VERBOSE} ]; then
  ANSIBLE_CMD="${ANSIBLE_CMD} -v"
fi

${ANSIBLE_CMD} -f 10 \
  -i ./ansible/inventory.ini \
  ./ansible/configure.yml | tee -a "${1}/run.log"

echo "Stage 4 complete"

exit 0
