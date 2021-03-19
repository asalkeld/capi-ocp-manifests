# POC for running CAPI on OpenShift 

## Running on AWS

Set following environmental variables:

```
export AWS_REGION=us-east-1
export AWS_ACCESS_KEY_ID=<your-access-key>
export AWS_SECRET_ACCESS_KEY=<your-secret-access-key>
export OS=<your-system-type> # Could be linux or darwin
export KUBECONFIG=<path-to-kubeconfig>
```

Edit `AWSMachineTemplate`(equivalent to ProviderSpec in MachineAPI) in `capa/capa-resources.yaml`. 
Replace `iamInstanceProfile, ami, subnet, additionalSecurityGroups` with your values(this step is normally done by installer in MAPI). You can pick this values from providerSpec of MAPI worker machine(`oc get machine -n openshift-machine-api`).

Run `deploy-poc-aws.sh` script.

At this moment CSRs should be approved manually because `cluster-machine-approver` doesn't work with CAPI. In about 5 minutes after creating machine you should see a pending CSR and manually approve it:
```
kubectl get csr
kubectl certificate approve <csr-name>
```
