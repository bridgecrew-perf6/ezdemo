#!/usr/bin/env bash

set -euo pipefail

EPIC_DL_URL=$(jq -r '.epic_latest' ./system.settings)
IS_HA=$(jq -r '.is_ha // false' ./system.settings)
IS_RUNTIME=$(jq -r '.is_runtime // false' ./system.settings)
# IS_MLOPS=$(jq -r '.is_mlops // false' ./system.settings)
IS_MAPR=$(jq -r '.is_mapr // false' ./system.settings)