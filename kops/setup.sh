#!/usr/bin/env bash

# Generate keys
ssh-keygen -f ~/.ssh/id_rsa -N ''

# Create S3 Bucket
export KOPS_STATE_STORE="kops-state-store-assessment132"
aws s3api create-bucket --bucket ${KOPS_STATE_STORE} --region eu-west-2 --create-bucket-configuration LocationConstraint=eu-west-2
aws s3api put-bucket-versioning --bucket ${KOPS_STATE_STORE} --versioning-configuration Status=Enabled
export KOPS_STATE_STORE="s3://"${KOPS_STATE_STORE}

# Export variables
export NAME="assessment132-dev.k8s.local" 
export SSH_PUBLIC_KEY="~/.ssh/id_rsa.pub"
export ZONES="eu-west-2a,eu-west-2b,eu-west-2c"
export NODE_SIZE="t2.medium"
export NODE_COUNT=3
export MASTER_SIZE="t2.small"
export ADMIN_ACCESS=$(curl -s http://checkip.amazonaws.com)/32
# Create the cluster
kops create cluster \
    --state "${KOPS_STATE_STORE}" \
    --name "${NAME}" \
    --cloud aws \
    --node-count ${NODE_COUNT} \
    --admin-access "${ADMIN_ACCESS}" \
    --zones "${ZONES}" \
    --master-zones "${ZONES}" \
    --node-size "${NODE_SIZE}" \
    --master-size "${MASTER_SIZE}" \
    --topology private \
    --networking calico \
    --ssh-public-key ${SSH_PUBLIC_KEY}
kops update cluster --name ${NAME} --yes --admin
kops validate cluster --wait 15m