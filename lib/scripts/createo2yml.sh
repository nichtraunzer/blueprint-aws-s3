#!/usr/bin/env bash
#
# Author: Josef Hartmann
#         josef.hartmann@boehringer-ingelheim.com
#
# This script creates terraform json output, converts it to yaml.
# This yaml file is used for loading terraform outputs as cinc-auditor/inspec inputs using option --input-file=<filename>
#
# This script can be used within Jenkins pipeline, inspec cli or with kitchen-terraform lifecycle hook.
#

set -e
set -o pipefail

if [ "x${KITCHEN_SUITE_NAME}" == "x" ]; then
  echo "Not running within kitchen."
  KITCHEN_SUITE_NAME="default"
  KITCHEN_INSTANCE_NAME="default-aws"
fi

CWD="$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd -P)"
TOJFILE=${CWD}/test/integration/${KITCHEN_SUITE_NAME}/files/tf-output.json
TOYFILE=${CWD}/test/integration/${KITCHEN_SUITE_NAME}/files/inputs-from-tfo.yml

pushd .

cd "${CWD}"/test/fixtures/${KITCHEN_SUITE_NAME}

#
# This workspace name is only set within kitchen-terraform
#
TF_WORKSPACE=kitchen-terraform-${KITCHEN_INSTANCE_NAME} terraform output -json > "${TOJFILE}"

# convert terraform outputs to yml
# symbolize_names adds ':' in front of the key: id -> :id
# symbolize_names is required, as kitchen-terraform outputs are created as inspec inputs using this type for keys.
#cat "${TOJFILE}" | jq 'with_entries(.value |= .value)|with_entries(.key = "output_" + .key)' | \
jq 'with_entries(.value |= .value)|with_entries(.key = "output_" + .key)' "${TOJFILE}" | \
  ruby -ryaml -rjson -e 'puts YAML.dump(JSON.parse(STDIN.read, :symbolize_names => true))' > "${TOYFILE}"

popd
