Postgres
========

A role to setup postgres in Galaxy, yielding the following objects:

* StatefulSet
* Service
* Secret
    * Stores the DB password

Role Variables
--------------

* `database_connection`: A dictionary of database configuration
    * `username`: User that owns and runs Postgres.
    * `password`: Database password.
    * `admin_password`: Initial password for the Pulp admin.
    * `sslmode` is valid for `external` databases only. The allowed values are: `prefer`, `disable`, `allow`, `require`, `verify-ca`, `verify-full`.

* `postgres_extra_settings`: A list of PostgreSQL configuration parameters to override or add
    * Each item is a dictionary with `setting` and `value` keys
    * `setting`: The PostgreSQL configuration parameter name
    * `value`: The value for the parameter (must be a string)
    * Example:
      ```yaml
      postgres_extra_settings:
        - setting: max_connections
          value: "499"
        - setting: ssl_ciphers
          value: "HIGH:!aNULL:!MD5"
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
