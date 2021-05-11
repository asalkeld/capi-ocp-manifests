# POC for running CAPI on OpenShift 

## Running on AWS

Set following environmental variables:

```
export KUBECONFIG=<path-to-kubeconfig>
```

Edit `AWSMachineTemplate`(equivalent to ProviderSpec in MachineAPI) in `examples/capa-resources.yaml`. 
Replace `iamInstanceProfile, ami, subnet, additionalSecurityGroups` with your values(this step is normally done by installer in MAPI). You can pick this values from providerSpec of MAPI worker machine(`oc get machine -n openshift-machine-api`).

Run `deploy-poc-aws.sh` script.
