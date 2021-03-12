#!/usr/bin/env bash

echo -e 'Install CAPI CRDs'

oc apply -f capi/capi-crds.yaml

echo -e 'Create namespace and run CAPI controllers'

oc apply -f capi/capi-components.yaml

echo -e 'Install CAPA CRDs'

oc apply -f capa/capa-crds.yaml

echo -e 'Run CAPA controllers in CAPI namespace'

AWS_B64ENCODED_CREDENTIALS=$(clusterawsadm bootstrap credentials encode-as-profile)

oc apply -f capa/capa-components.yaml

echo -e 'Create worker user data for CAPI'

USERDATA=$(oc get secret worker-user-data -n openshift-machine-api -o json | jq '.data.userData')
oc create secret generic worker-user-data -n ocp-cluster-api --from-literal=value=$USERDATA

echo -e 'Create CAPI resources: Cluster, AWSCluster, MachineSet, AWSMachineTemplate'

oc apply -f capa/capa-resources.yaml
