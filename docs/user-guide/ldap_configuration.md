## LDAP configuration

LDAP can be configured by adding pulp settings as specified in [the documentation](https://ansible.readthedocs.io/projects/galaxy-ng/en/latest/integration/ldap.html).
The bind password () can be masked by storing the password in a secret. You need to specify the ```ldap_bind_password_secret``` in the spec:

```yaml
---
spec:
  ...
  ldap_bind_password_secret: <name-of-your-secret>
```

The secret should be formatted as follows:

```yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: <name-of-your-secret>
  namespace: <target-namespace>
type: Opaque
stringData:
  password: <bind-user-password>
```