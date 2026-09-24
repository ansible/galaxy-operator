Galaxy Content
============

A role to setup content serving in Galaxy, yielding the following objects:

* Deployment
* Service

Role Variables
--------------

* `content`: A dictionary of galaxy-content configuration
    * `replicas`: Number of pod replicas.
    * `log_level`: The desired log level.
* `image`: The image name. Default: quay.io/ansible/galaxy-ng
* `image_version`: The image tag. Default: main
* `gunicorn_timeout`: The timeout for the gunicorn process. Default: computed based on `client_request_timeout`

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
