# Configuring Content Signing

As an administrator, you can configure your Galaxy instance to sign collections. This ensures the integrity of the content and allows consumers of the content to verify its authenticity.

This guide will walk you through the process of configuring content signing for your Galaxy instance using the galaxy-operator.

## Prerequisites

Before you begin, you will need:

*   A GPG key pair. If you don't have one, you can generate one using the `gpg --full-generate-key` command.
*   A signing script that can be used by the signing service.

## 1. Create a Signing Script

The signing service in Galaxy uses a script to sign content. This script needs to be provided as a ConfigMap to the operator.

The script must:

*   Accept a single argument: the path to the file to be signed.
*   Generate an ASCII-armored detached GPG signature for the file.
*   Use the GPG key specified by the `PULP_SIGNING_KEY_FINGERPRINT` environment variable.
*   Print a JSON object to standard output with the following format: `{"file": "filename", "signature": "filename.asc"}`.

Here is an example signing script:

```bash
#!/usr/bin/env bash

FILE_PATH=$1
SIGNATURE_PATH="$1.asc"

ADMIN_ID="$PULP_SIGNING_KEY_FINGERPRINT"
PASSWORD="password" # Replace with the password for your GPG key if it has one

# Create a detached signature
gpg --quiet --batch --pinentry-mode loopback --yes --passphrase \
   $PASSWORD --homedir ~/.gnupg/ --detach-sign --default-key $ADMIN_ID \
   --armor --output $SIGNATURE_PATH $FILE_PATH

# Check the exit status
STATUS=$?
if [ $STATUS -eq 0 ]; then
   echo {"file": "$FILE_PATH", "signature": "$SIGNATURE_PATH"}
else
   exit $STATUS
fi
```

### Create the ConfigMap

Once you have your signing script, you need to create a ConfigMap that contains it. The ConfigMap should have a key for `collection_sign.sh` and `container_sign.sh`. For this example, we will use the same script for both.

Create a file named `signing-scripts.configmap.yaml` with the following content:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: signing-scripts
data:
  collection_sign.sh: |-
      #!/usr/bin/env bash

      FILE_PATH=$1
      SIGNATURE_PATH=$1.asc

      ADMIN_ID="$PULP_SIGNING_KEY_FINGERPRINT"
      PASSWORD="password"

      # Create a detached signature
      gpg --quiet --batch --pinentry-mode loopback --yes --passphrase \
        $PASSWORD --homedir /var/lib/pulp/.gnupg --detach-sign --default-key $ADMIN_ID \
        --armor --output $SIGNATURE_PATH $FILE_PATH

      # Check the exit status
      STATUS=$?
      if [ $STATUS -eq 0 ]; then
        echo {\"file\": \"$FILE_PATH\", \"signature\": \"$SIGNATURE_PATH\"}
      else
        exit $STATUS
      fi
  container_sign.sh: |-
    #!/usr/bin/env bash

    # galaxy_container SigningService will pass the next 4 variables to the script.
    MANIFEST_PATH=$1
    FINGERPRINT="$PULP_SIGNING_KEY_FINGERPRINT"
    IMAGE_REFERENCE="$REFERENCE"
    SIGNATURE_PATH="$SIG_PATH"

    # Create container signature using skopeo
    skopeo standalone-sign \
      $MANIFEST_PATH \
      $IMAGE_REFERENCE \
      $FINGERPRINT \
      --output $SIGNATURE_PATH

    # Optionally pass the passphrase to the key if password protected.
    # --passphrase-file /path/to/key_password.txt

    # Check the exit status
    STATUS=$?
    if [ $STATUS -eq 0 ]; then
      echo {\"signature_path\": \"$SIGNATURE_PATH\"}
    else
      exit $STATUS
    fi
```

Then, apply the ConfigMap to your cluster:

```bash
kubectl apply -f signing-scripts.configmap.yaml
```

## 2. Create the GPG Key Secret

Next, you need to create a Kubernetes Secret that contains your GPG public key. The operator will mount this secret into the Galaxy pods.

First, export your GPG public key to a file:

```bash
gpg --export --armor <your-gpg-key-id> > signing_service.gpg
```

Then, create a secret from this file:

```bash
kubectl create secret generic signing-galaxy --from-file=signing_service.gpg
```

The secret should have a key named `signing_service.gpg`.

## 3. Configure the Galaxy CR

Finally, you need to update your `Galaxy` custom resource to enable content signing. You will need to set the `signing_secret` and `signing_scripts_configmap` fields.

Here is an example of a `Galaxy` CR with content signing configured:

```yaml
apiVersion: galaxy.ansible.com/v1beta1
kind: Galaxy
metadata:
  name: example-galaxy
spec:
  ...
  signing_secret: "signing-galaxy"
  signing_scripts_configmap: "signing-scripts"
  ...
```

Apply the changes to your `Galaxy` CR:

```bash
kubectl apply -f your-galaxy-cr.yaml
```

Once the operator has reconciled the changes, your Galaxy instance will be configured for content signing.

## Verification

You can verify that content signing is working by uploading a collection and checking for a signature. You can also check the logs of the `galaxy-api` and `galaxy-worker` pods for any errors related to the signing service.
