# POC for running CAPI on OpenShift 

This repo is intended to help with deploying CAPI components to OpenShift.

## Running on AWS

There are couple prerequistes that need to be fullfilled in order to run CAPI on AWS.

- Download the latest version of [clusterawsadm](https://github.com/kubernetes-sigs/cluster-api-provider-aws/releases). This is a CLI tool for helping with deploying on AWS. You might want to place it in you path.
- Set following env variables: 

```
export AWS_REGION=us-east-1 # This is used to help encode your environment variables
export AWS_ACCESS_KEY_ID=<your-access-key>
export AWS_SECRET_ACCESS_KEY=<your-secret-access-key>
export AWS_B64ENCODED_CREDENTIALS=$(clusterawsadm bootstrap credentials encode-as-profile)
```
- Edit `AWSMachineTemplate`(equivalent to ProviderSpec in MachineAPI) in `capa/capa-resources.yaml`. 
Replace `iamInstanceProfile, ami, subnet, additionalSecurityGroups` with your values(this step is normally done by installer in MAPI).

- Run `deploy-poc-aws.sh` script
