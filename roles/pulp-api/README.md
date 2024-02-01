Pulp API
========

A role to setup the Pulp 3 API, yielding the following objects:

* Deployment
* Service
* PersistentVolumeClaim
    * This is created only when choosing filesystem storage e.g. `storage_type=File`
* Secret
    * For the admin password
    * For the [pulp settings](https://docs.pulpproject.org/pulpcore/configuration/settings.html)
    * For encrypting sensitive DB fields


Role Variables
--------------

* `api`: A dictionary of pulp-api configuration
    * `replicas`: Number of pod replicas.
    * `log_level`: The desired log level.
* `default_settings`: A nested dictionary that will be combined with custom values from the user's
    *setting.py*. The keys of this dictionary are variable names, and the values should be expressed using the
    [Dynaconf syntax](https://dynaconf.readthedocs.io/en/latest/guides/environment_variables.html#precedence-and-type-casting)
    Please see [pulpcore configuration docs](https://docs.pulpproject.org/en/master/nightly/installation/configuration.html#id2)
    for documentation on the possible variable names and their values.
    * `debug`: Wether to run pulp in debug mode.
* `image`: The image name. Default: quay.io/ansible/galaxy-ng
* `image_version`: The image tag. Default: latest
* `gunicorn_timeout`: The timeout for the gunicorn process. Default: 90
* `storage_type`: A string for specifying storage configuration type.
* `file_storage_access_mode`: The access mode for the volume.
* `file_storage_size`: The storage size.
* `object_storage_s3_secret`:The kubernetes secret with s3 storage configuration information.
* `object_storage_azure_secret`:The kubernetes secret with Azure blob storage configuration information.

Requirements
------------

Requires the `openshift` Python library to interact with Kubernetes: `pip install openshift`.

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

[Pulp Team](https://pulpproject.org/)
