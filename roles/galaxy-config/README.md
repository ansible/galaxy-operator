Galaxy Config
============

A role to setup configuration files for Galaxy, yielding the following objects:

* Secret

Role Variables
--------------

* `extra_settings_files`: A dictionary to specify extra settings files. Refer to [the Advanced Configuration in the User Guide](../user-guide/advanced-configuration/extra-settings.md) for more information. Default: `{}`

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
