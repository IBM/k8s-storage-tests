# Storage Validation Tool

Kubernetes has gained a lot of momentum with storage vendors providing support on various container orchestration platforms with [CSI](https://kubernetes-csi.github.io/docs/drivers.html) drivers and other mechanisms.

It becomes essential for platform administrators to quickly validate a storage platform for their modernized workloads on IBM Cloud Paks and check its readiness level.

This Ansible Playbook helps functionally validate a storage on `ReadWriteOnce` and `ReadWriteMany` volumes. Note that these tests covers readiness and are only meant to be a pre-cursor to a full blown test with actual Cloud Pak workloads.

The following tests are performed:

 - Dynamic provisioning of a volume
 - Mounting volume from a node
 - Sequential [Read Write Consistency](./roles/storage-readiness/README.md#read-write-tests) from single and multiple nodes
 - Parallel Read Write Consistency from single and multiple nodes
 - Parallel Read Write Consistency across multiple threads
 - Accessibility based on POSIX compliant [Group ID Permissions](./roles/storage-readiness/README.md#gid-tests)
 - [SubPath](https://kubernetes.io/docs/concepts/storage/volumes/#using-subpath) test for volumes
 - [File Locking](https://pubs.opengroup.org/onlinepubs/9699919799/functions/fcntl.html) test
 
### Prerequisites

- Ensure you have python 3.6 or later and [pip](https://pip.pypa.io/en/stable/installation/) 21.1.3 or later installed

  `python --version`

  `pip --version`

- Install Ansible 2.10.5 or later
  
  `pip install ansible==2.10.5`

- Install ansible k8s modules

  `pip install openshift`
   
  `ansible-galaxy collection install operator_sdk.util`
  
  `ansible-galaxy collection install community.kubernetes`
  
- Install [OpenShift Client 4.6 or later](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/4.6.31) based on your OS. 
  
- Access to the OpenShift Cluster (at least 3 compute nodes) setup with RWX and RWO storage classes with cluster admin access.

### Setup

 - Clone this git repo to your client
  
 - Update the `params.yml` file with your OCP URL and Credentials
 
   ```
    ocp_url: https://<required>:6443
    ocp_username: <required>
    ocp_password: <required>
    ocp_token: <required if user/password not available>
   ```
  
 - Update the `params.yml` file for the `required` storage parameters
 
    ```
    storageClass_ReadWriteOnce: <required> 
    storageClass_ReadWriteMany: <required> 
    storage_validation_namespace: <required>
    ```
  
### Running the Playbook

 - From the root of this repository, run:
  
  ```bash
    ansible-playbook main.yml --extra-vars "@./params.yml" | tee output.log
  ```

  If the playbook fails to run due to SSL verification error, you can disable it by setting this environment variable before running the playbook

  ```
  export K8S_AUTH_VERIFY_SSL=no
  ```

 - On a successful run, you should see the following output

 ```
  ######################## MOUNT TESTS PASSED FOR ReadWriteOnce Volume  #################################
  ######################## MOUNT TESTS PASSED FOR ReadWriteMany Volume  #################################
  ######################## SEQUENTIAL READ WRITE TEST PASSED FOR ReadWriteOnce Volume ###################
  ######################## SEQUENTIAL READ WRITE TEST PASSED FOR ReadWriteMany Volume ###################
  ######################## SINGLE THREAD PARALLEL READ WRITE TEST PASSED for ReadWriteOnce ##############
  ######################## SINGLE THREAD PARALLEL READ WRITE TEST PASSED for ReadWriteMany ##############
  ######################## PARALLEL READ WRTIE TEST PASSED FOR ReadWriteOnce ############################
  ######################## MULTI NODE PARALLEL READ WRTIE TEST PASSED FOR ReadWriteMany #################
  ######################## FILE PERMISSIONS TEST PASSED FOR ReadWriteMany Volume ########################
  ######################## FILE PERMISSIONS TEST PASSED FOR ReadWriteOnce Volume ########################
  ######################## SUB PATH TEST PASSED FOR ReadWriteMany Volume ################################
  ######################### FILE LOCK TESTS PASSED FOR ReadWriteMany Volume #############################
 ```

## Clean-up Resources

Delete the kuberbetes namespace that you created in [Setup](#setup), you can also run these commands to clean up the 
resources in the namespace

```
oc delete job $(oc get jobs -n <storage_validation_namespace> | awk '{ print $1 }') -n <storage_validation_namespace>
oc delete cm $(oc get cm -n <storage_validation_namespace> | awk '{ print $1 }') -n <storage_validation_namespace>
oc delete pvc $(oc get pvc -n <storage_validation_namespace> | awk '{ print $1 }') -n <storage_validation_namespace>
oc delete scc zz-fsgroup-scc
```
