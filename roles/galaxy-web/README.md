Galaxy Web
========

A role to setup Galaxy NGINX web, yielding the following objects:

* Deployment
* Service
* ConfigMap
    *  Stores NGINX configs

Role Variables
--------------

* `web`: A dictionary of pulp-web configuration
    * `replicas`: Number of pod replicas.
* `image_web`: The image name. Default: quay.io/ansible/galaxy-ui
* `image_web_version`: The image tag. Default: main
* `nginx_client_max_body_size`: Sets the maximum allowed size of the client request body.

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
