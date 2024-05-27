# Extra Settings

With `pulp_settings` and `extra_settings_files`, you can pass multiple custom settings to Galaxy NG via the Galaxy Operator.

!!! note
    If the same setting is set in both `pulp_settings` and `extra_settings_files`, the setting in `extra_settings_files` will take precedence.

## Add extra settings with `pulp_settings`

You can pass extra settings by specifying the pair of the setting name and value as the `pulp_settings` parameter.

The settings passed via `pulp_settings` will be appended to the `/etc/pulp/settings.py`.

| Name           | Description    | Default   |
| -------------- | -------------- | --------- |
| pulp_settings  | Extra settings | `[]`      |

Example configuration of `pulp_settings` parameter

```yaml
spec:
  pulp_settings:
    GALAXY_ENABLE_UNAUTHENTICATED_COLLECTION_ACCESS: "True"
    GALAXY_ENABLE_UNAUTHENTICATED_COLLECTION_DOWNLOAD: "True"
```

## Add extra settings with `extra_settings_files`

You can pass extra settings by specifying the additional settings files in the ConfigMaps or Secrets as the `extra_settings_files` parameter.

The settings files passed via `extra_settings_files` will be mounted as the files under the `/etc/pulp/conf.d`.

| Name                 | Description          | Default   |
| -------------------- | -------------------- | --------- |
| extra_settings_files | Extra settings files | `{}`      |

!!! note
    If the same setting is set in multiple files in `extra_settings_files`, it would be difficult to predict which would be adopted since these files are loaded in arbitrary order that [`glob`](https://docs.python.org/3/library/glob.html) returns. For a reliable setting, do not include the same key in more than one file.

Create ConfigMaps or Secrets that contain custom settings files (`*.py`).

```python title="custom_feature_flags.py"
GALAXY_FEATURE_FLAGS = {
  "execution_environments": False,
  "dynaconf_merge": True,
}
```

```python title="custom_misc_settings.py"
GALAXY_AUTHENTICATION_CLASSES = [
    "galaxy_ng.app.auth.session.SessionAuthentication",
    "rest_framework.authentication.TokenAuthentication",
    "rest_framework.authentication.BasicAuthentication",
]
GALAXY_MINIMUM_PASSWORD_LENGTH = 15
SESSION_COOKIE_AGE = 3600
GALAXY_ENABLE_UNAUTHENTICATED_COLLECTION_ACCESS = True
GALAXY_ENABLE_UNAUTHENTICATED_COLLECTION_DOWNLOAD = True
GALAXY_COLLECTION_SIGNING_SERVICE = None
GALAXY_CONTAINER_SIGNING_SERVICE = None
TOKEN_AUTH_DISABLED = True
```

```python title="custom_ldap.py"
AUTH_LDAP_SERVER_URI = "ldap://ldap:10389"
AUTH_LDAP_BIND_DN = "cn=admin,dc=planetexpress,dc=com"
AUTH_LDAP_BIND_PASSWORD = "GoodNewsEveryone"
AUTH_LDAP_USER_SEARCH_BASE_DN = "ou=people,dc=planetexpress,dc=com"
AUTH_LDAP_USER_SEARCH_SCOPE = "SUBTREE"
AUTH_LDAP_USER_SEARCH_FILTER = "(uid=%(user)s)"
AUTH_LDAP_GROUP_SEARCH_BASE_DN = "ou=people,dc=planetexpress,dc=com"
AUTH_LDAP_GROUP_SEARCH_SCOPE = "SUBTREE"
AUTH_LDAP_GROUP_SEARCH_FILTER = "(objectClass=Group)"
AUTH_LDAP_GROUP_TYPE_CLASS = "django_auth_ldap.config:GroupOfNamesType"
```

```bash title="Create ConfigMap and Secret"
# Create ConfigMap
kubectl create configmap my-custom-settings \
  --from-file /PATH/TO/YOUR/custom_feature_flags.py \
  --from-file /PATH/TO/YOUR/custom_misc_settings.py

# Create Secret
kubectl create secret generic my-custom-passwords \
  --from-file /PATH/TO/YOUR/custom_ldap.py
```

Then specify them in the Galaxy CR spec. Here is an example configuration of `extra_settings_files` parameter.

```yaml
spec:
  extra_settings_files:
    configmaps:
      - name: my-custom-settings         # The name of the ConfigMap
        key: custom_feature_flags.py     # The key in the ConfigMap, which means the file name
      - name: my-custom-settings
        key: custom_misc_settings.py
    secrets:
      - name: my-custom-passwords        # The name of the Secret
        key: custom_ldap.py              # The key in the Secret, which means the file name
```

!!! warning "Restriction"
    There are some restrictions on the ConfigMaps or Secrets used in `extra_settings_files`.

    - The keys in ConfigMaps or Secrets MUST be the name of python files and MUST end with `.py`
    - The keys in ConfigMaps or Secrets MUST consists of alphanumeric characters, `-`, `_` or `.`
    - The keys in ConfigMaps or Secrets are converted to the following strings, which MUST not exceed 63 characters
        - Keys in ConfigMaps: `<instance name>-<KEY>-configmap`
        - Keys in Secrets: `<instance name>-<KEY>-secret`

    Refer to the Kubernetes documentations ([[1]](https://kubernetes.io/docs/reference/kubernetes-api/config-and-storage-resources/config-map-v1/), [[2]](https://kubernetes.io/docs/reference/kubernetes-api/config-and-storage-resources/secret-v1/), [[3]](https://kubernetes.io/docs/reference/kubernetes-api/config-and-storage-resources/volume/), [[4]](https://kubernetes.io/docs/concepts/overview/working-with-objects/names/)) for more information about character types and length restrictions.
