#!/usr/bin/env bash
# =============================================================================
# Copyright 2022 Hewlett Packard Enterprise
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# =============================================================================


VOLUMES=()
CONFIG_FILES=("aws_config.json" "azure_config.json" "vmware_config.json" "kvm_config.json" "ovirt_config.json" "mac_config.json")
for file in "${CONFIG_FILES[@]}"
do
  target="${file%_*}"
  # [[ -f "./${file}" ]] && VOLUMES="--mount=type=bind,source="$(pwd)"/${file},target=/app/server/${target}/config.json ${VOLUMES}"
  [[ -f "./${file}" ]] && VOLUMES+=("$(pwd)/${file}:/app/server/${target}/config.json:rw")
done

# echo "${VOLUMES[*]}"
printf -v joined ' -v %s' "${VOLUMES[@]}"
# echo "${joined}"
## run at the background with web service exposed at 4000
docker run --name ezdemo --pull always -d -p 4000:4000 -p 8443:8443 -p 9443:9443 ${joined} erdincka/ezdemo:latest

exit 0
