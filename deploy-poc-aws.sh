#!/usr/bin/env bash

GREEN='\033[0;32m'
NOCOLOR='\033[0m'

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

echo -e "${GREEN}Patch CAPI cluster status to Ready${NOCOLOR}"

./cluster-patch

