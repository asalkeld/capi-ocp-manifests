#!/usr/bin/env bash

GREEN='\033[0;32m'
NOCOLOR='\033[0m'

[ -z "$OS" ] && echo "OS not set"; exit 0;
[ -z "$AWS_REGION" ] && echo "AWS_REGION not set"; exit 0;
[ -z "$AWS_ACCESS_KEY_ID" ] && echo "AWS_ACCESS_KEY_ID not set"; exit 0;
[ -z "$AWS_SECRET_ACCESS_KEY" ] && echo "AWS_SECRET_ACCESS_KEY not set"; exit 0;
[ -z "$KUBECONFIG" ] && echo "KUBECONFIG not set"; exit 0;

echo -e "${GREEN}Downloading CLIs${NOCOLOR}"

curl -L https://github.com/kubernetes-sigs/cluster-api-provider-aws/releases/download/v0.6.4/clusterawsadm-${OS}-amd64 -o clusterawsadm
curl -L https://github.com/cloud-team-poc/cluster-patch/releases/download/v1/cluster-patch-${OS} -o cluster-patch

chmod +x ./clusterawsadm
chmod +x ./cluster-patch

echo -e "${GREEN}Install CAPI CRDs${NOCOLOR}"

oc apply -f capi/capi-crds.yaml

echo -e "${GREEN}Create namespace and run CAPI controllers${NOCOLOR}"

oc apply -f capi/capi-components.yaml

echo -e "${GREEN}Install CAPA CRDs${NOCOLOR}"

oc apply -f capa/capa-crds.yaml

echo -e "${GREEN}Run CAPA controllers in CAPI namespace${NOCOLOR}"

AWS_B64ENCODED_CREDENTIALS=$(./clusterawsadm bootstrap credentials encode-as-profile)

envsubst < capa/capa-components.yaml | oc create -f -

echo -e "${GREEN}Create worker user data for CAPI${NOCOLOR}"

USERDATA=$(oc get secret worker-user-data -n openshift-machine-api -o json | jq -r ".data.userData" | base64 --decode)
oc create secret generic worker-user-data -n ocp-cluster-api --from-literal=value=$USERDATA
unset USERDATA

echo -e "${GREEN}Create kubeconfig for CAPI cluster${NOCOLOR}"

oc create secret generic capi-ocp-aws-kubeconfig -n ocp-cluster-api --from-file=value=$KUBECONFIG

echo -e "${GREEN}Create CAPI resources: Cluster, AWSCluster, MachineSet, AWSMachineTemplate${NOCOLOR}"

oc apply -f capa/capa-resources.yaml

echo -e "${GREEN}Patch CAPA cluster status to Ready${NOCOLOR}"

./cluster-patch

