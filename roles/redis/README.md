Redis
=====

A role to setup Galaxyredis, yielding the following objects:

* Deployment
* Service
* PersistentVolumeClaim

Role Variables
--------------

* `redis_image`: The redis image name. Default: redis:latest

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
