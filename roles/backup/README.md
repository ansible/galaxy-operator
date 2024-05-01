Backup
========

The purpose of this role is to create a backup of your Galaxy deployment.  This includes:
  - backup of the PostgreSQL database
  - custom user config file

Role Variables
--------------

* `deployment_name`: The name of the galaxy custom resource to backup
* `backup_pvc`: The name of the PVC to uses for backup
* `backup_storage_requirements`: The size of storage for the PVC created by operator if one is not supplied
* `backup_resource_requirements`: The size of storage for the PVC created by operator if one is not supplied
* `backup_storage_class`: The storage class to be used for the backup PVC
* `postgres_configuration_secret`: The postgres_configuration_secret


Defining resources limits and request for backup CR

```
backup_resource_requirements:
  limits:
    cpu: "1000m"
    memory: "4096Mi"
  requests:
    cpu: "25m"
    memory: "32Mi"
```


Requirements
------------

Requires the `kubernetes` Python library to interact with Kubernetes: `pip install kubernetes`.

Dependencies
------------

collections:

  - kubernetes.core
  - operator_sdk.util

License
-------

GPLv2+

Author Information
------------------

[Galaxy-Operator Team](https://github.com/ansible/galaxy-operator)
