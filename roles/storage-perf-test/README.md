## Running the Storage Performance Role
* Install the requirements:
```bash
pip install -r storage_perf_files/requirements.txt
```
* Login to the cluster you want to use:
```bash
oc login --server=.. --token=..
```
* Enable the Storage Performance Test and disable all other tests:
  * Open the `main.yml` file in the root of this repository
  * Set storage_tests to `true` and other tests to false
* In the `roles/storage-perf-test/vars/main.yml` file, select and customize the tests you want to run.
* Run playbook:
  * From the root of this repository, run:
    ```bash
    ansible-playbook main.yaml
    ```
* When completed, a `result.csv` file will be generated.