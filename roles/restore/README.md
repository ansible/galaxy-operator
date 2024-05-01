Restore
========

The purpose of this role is to restore your Galaxy deployment from a backup.  This includes:
  - backup of the PostgreSQL database
  - custom user config file

Role Variables
--------------

* `backup_name`: The name of the galaxy backup custom resource to restore from
* `postgres_label_selector`: The label selector for an external container based database
* `restore_resource_requirements`: The resources limits and requests for restore CR


Defining resources limits and requests for restore CR

```
restore_resource_requirements:
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
