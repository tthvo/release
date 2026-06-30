#!/bin/bash

set -euo pipefail

export GOOGLE_CLOUD_UNIVERSE_DOMAIN="${GOOGLE_CLOUD_UNIVERSE_DOMAIN:-apis-berlin-build0.goog}"

CRED_FILE="${CLUSTER_PROFILE_DIR}/gce.json"
if [[ ! -f "${CRED_FILE}" ]]; then
  echo "ERROR: WIF credential config not found at ${CRED_FILE}"
  exit 1
fi

if ! CRED_TYPE=$(jq -er '.type' "${CRED_FILE}" 2>/dev/null); then
  echo "ERROR: Invalid WIF credential config at ${CRED_FILE}"
  exit 1
fi
if [[ "${CRED_TYPE}" != "external_account" ]]; then
  echo "ERROR: Expected external_account credential type, got ${CRED_TYPE}"
  exit 1
fi

echo "GCD WIF configuration validated"
echo "  GOOGLE_CLOUD_UNIVERSE_DOMAIN=${GOOGLE_CLOUD_UNIVERSE_DOMAIN}"
echo "  Credential type: ${CRED_TYPE}"
