Galaxy Worker
===========

A role to setup Galaxy worker, yielding the following objects:

* Deployment

Role Variables
--------------

* `worker`: A dictionary of galaxy-worker configuration
    * `replicas`: Number of pod replicas.
* `image`: The image name. Default: quay.io/ansible/galaxy-ng
* `image_version`: The image tag. Default: main

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
