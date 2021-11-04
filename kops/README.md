# Configure and deploy the k8s cluster using Kops

In this section we will create an AWS S3 bucket, configure our cluster via Kops and deploy it. This section can be run from the [setup script](./setup.sh) `cd ~/Devops-Assessment/kops && chmod +x setup.sh && ./setup.sh`

### Create a S3 Bucket

In order to create a S3 Bucket we need to give it a name and then use it to run the creation command:
```bash
export KOPS_STATE_STORE="kops-state-store-assessment132"
aws s3api create-bucket --bucket ${KOPS_STATE_STORE} --region eu-west-2 --create-bucket-configuration LocationConstraint=eu-west-2
aws s3api put-bucket-versioning --bucket ${KOPS_STATE_STORE} --versioning-configuration Status=Enabled
export KOPS_STATE_STORE="s3://"${KOPS_STATE_STORE}
```

### Kops variables and cluster deployment

* We need to create public admin ssh key for the admin user (access nodes): `ssh-keygen -f ~/.ssh/id_rsa -N ''`
* Create the variables for the deployment then we deploy the cluster with `kops create cluster`:
```bash
export NAME="assessment132-dev.k8s.local" 
export SSH_PUBLIC_KEY="~/.ssh/id_rsa.pub"
export ZONES="eu-west-2a,eu-west-2b,eu-west-2c"
export NODE_SIZE="t2.medium"
export NODE_COUNT=3
export MASTER_SIZE="t2.small"
export ADMIN_ACCESS=$(curl -s http://checkip.amazonaws.com)/32
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
```
It takes around 15m~ for the cluster to be ready.

### Add additional configurations to the cluster config
* Run the command `kops edit cluster` and add this additional configuration in the spec group
```yaml
additionalPolicies:
    master: |
      [
        {
          "Effect": "Allow",
          "Action": "iam:CreateServiceLinkedRole",
          "Resource": "arn:aws:iam::*:role/aws-service-role/*"
         },
         {
           "Effect": "Allow",
           "Action": [
             "ec2:DescribeAccountAttributes",
             "ec2:DescribeInternetGateways"
            ],
           "Resource": "*"
         },
         {
            "Effect": "Allow",
            "Action": "elasticloadbalancing:*",
            "Resource": "*"
         }
      ]
```
* Should end up looking like this:
```yaml
...
kind: Cluster
metadata:
  creationTimestamp: "2021-11-04T17:16:40Z"
  name: assessment132-dev.k8s.local
spec:
  additionalPolicies:
    master: |
      [
        {
          "Effect": "Allow",
          "Action": "iam:CreateServiceLinkedRole",
          "Resource": "arn:aws:iam::*:role/aws-service-role/*"
         },
         {
           "Effect": "Allow",
           "Action": [
             "ec2:DescribeAccountAttributes",
             "ec2:DescribeInternetGateways"
            ],
           "Resource": "*"
         },
         {
            "Effect": "Allow",
            "Action": "elasticloadbalancing:*",
            "Resource": "*"
         }
      ]
  api:
    loadBalancer:
      class: Classic
...
```
* Then just run `kops update cluster --yes` to apply the changes
<p align="right">
    <a href="https://github.com/tik-png/Devops-Assessment/tree/main/kubernetes">Next: Configure and deploy the kubernetes services ▶️</a>
</p>