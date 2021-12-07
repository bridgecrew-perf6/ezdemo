#!/usr/bin/env bash

set -euo pipefail

source ./settings.sh
### These settings coming from system, not the user

pushd "${1}" > /dev/null
   TF_IN_AUTOMATION=1 terraform apply \
      -no-color \
      -parallelism 10 \
      -auto-approve=true \
      -var-file=<(cat ./*.tfvars) \
      -var="epic_dl_url=${EPIC_DL_URL}" \
      -var="is_ha=${IS_HA}" \
      -var="is_runtime=${IS_RUNTIME}" \
      -var="is_mapr=${IS_MAPR}"
      # -var="client_cidr_block=$(curl -s http://ipinfo.io/ip)/32"
   # Save output
   TF_IN_AUTOMATION=1 terraform output -json > ../generated/output.json
popd > /dev/null

echo "Wait for nodes to be ready..."
sleep 120

echo "Stage 2 complete"
# ./03-install.sh "${1}"

exit 0