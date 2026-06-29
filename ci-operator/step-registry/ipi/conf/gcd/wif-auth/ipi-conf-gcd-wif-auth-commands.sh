#!/bin/bash

set -euo pipefail

export AWS_CONFIG_FILE=/var/run/secrets/aws/config/config
export AWS_PROFILE=hub

export GOOGLE_CLOUD_UNIVERSE_DOMAIN="${GOOGLE_CLOUD_UNIVERSE_DOMAIN:-apis-berlin-build0.goog}"

CRED_FILE="${CLUSTER_PROFILE_DIR}/gce.json"
if [[ ! -f "${CRED_FILE}" ]]; then
  echo "ERROR: WIF credential config not found at ${CRED_FILE}"
  exit 1
fi

echo "Authenticating to GCD via Workload Identity Federation..."

[[ $- == *x* ]] && WAS_TRACING=true || WAS_TRACING=false
set +x

gcloud auth login --cred-file "${CRED_FILE}" --quiet

$WAS_TRACING && set -x

echo "GCD WIF authentication configured"
gcloud auth list
