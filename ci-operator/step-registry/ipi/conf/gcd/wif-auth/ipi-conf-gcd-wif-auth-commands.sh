#!/bin/bash

set -euo pipefail

export AWS_CONFIG_FILE="${AWS_CONFIG_FILE:-/var/run/secrets/aws/config/config}"
export AWS_PROFILE="${AWS_PROFILE:-hub}"

export GOOGLE_CLOUD_UNIVERSE_DOMAIN="${GOOGLE_CLOUD_UNIVERSE_DOMAIN:-apis-berlin-build0.goog}"

CRED_FILE="${CLUSTER_PROFILE_DIR}/gce.json"
if [[ ! -f "${CRED_FILE}" ]]; then
  echo "ERROR: WIF credential config not found at ${CRED_FILE}"
  exit 1
fi

echo "GCD WIF authentication configured"
echo "  AWS_CONFIG_FILE=${AWS_CONFIG_FILE}"
echo "  AWS_PROFILE=${AWS_PROFILE}"
echo "  GOOGLE_CLOUD_UNIVERSE_DOMAIN=${GOOGLE_CLOUD_UNIVERSE_DOMAIN}"
echo "  Credential config: ${CRED_FILE}"
