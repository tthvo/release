#!/bin/bash

set -o nounset
set -o errexit
set -o pipefail

if test -f "${SHARED_DIR}/proxy-conf.sh"; then
    # shellcheck disable=SC1091
    source "${SHARED_DIR}/proxy-conf.sh"
fi

export AWS_SHARED_CREDENTIALS_FILE="${CLUSTER_PROFILE_DIR}/.awscred"
export KUBECONFIG="${SHARED_DIR}/kubeconfig"

REGION="${LEASED_RESOURCE}"
export AWS_DEFAULT_REGION="${REGION}"

PLATFORM=$(oc get infrastructure cluster -o jsonpath='{.status.platformStatus.type}')
if [[ "${PLATFORM}" != "AWS" ]]; then
    echo "Platform is ${PLATFORM}, not AWS. Skipping."
    exit 0
fi

SOURCE_VERSION="$(oc get clusterversion --no-headers | awk '{print $2}')"
SOURCE_MAJOR_VERSION="$(echo "${SOURCE_VERSION}" | cut -f1 -d.)"

if [[ "${SOURCE_MAJOR_VERSION}" -ge 5 ]]; then
    echo "Cluster is already on ${SOURCE_VERSION}, IAM permissions were provisioned at install time. Skipping."
    exit 0
fi

echo "Cluster is on ${SOURCE_VERSION}, attaching upgrade IAM policy to master role."

INFRA_ID=$(oc get infrastructure cluster -o jsonpath='{.status.infrastructureName}')
if [[ -z "${INFRA_ID}" ]]; then
    echo "ERROR: Could not determine cluster infrastructure ID"
    exit 1
fi
echo "Cluster infrastructure ID: ${INFRA_ID}"

cat >"${ARTIFACT_DIR}/iam-master-upgrade-policy.json" <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:SetSecurityGroups"
            ],
            "Resource": "*"
        }
    ]
}
EOF

MASTER_ROLE="${INFRA_ID}-master-role"
POLICY_NAME="${INFRA_ID}-master-upgrade-policy"
echo "Adding inline policy ${POLICY_NAME} to role: ${MASTER_ROLE}"
aws iam put-role-policy \
    --role-name "${MASTER_ROLE}" \
    --policy-name "${POLICY_NAME}" \
    --policy-document "file://${ARTIFACT_DIR}/iam-master-upgrade-policy.json"
echo "Successfully added inline policy to ${MASTER_ROLE}"
