#!/bin/bash

set -xe

# get galaxy admin password
GALAXY_ADMIN_PASSWORD=$(kubectl get secret/example-galaxy-admin-password -ojsonpath='{.data.password}'|base64 -d)

# verify the list of signing services (keeping it in a different variable to make troubleshooting/debug easier)
SIGNING_SVC=$(kubectl exec deployment/example-galaxy-api -- curl  -u admin:$GALAXY_ADMIN_PASSWORD -sL localhost:24817/galaxy/api/v3/signing-services/)

# get only the count of services found
SVC_COUNT=$(echo $SIGNING_SVC | jq .count)

# check if the 2 services were found
if [[ $SVC_COUNT != 2 ]] ; then
  echo "Could not find all signing services!"
  exit 1
fi

# check if the the gpg key is in the api's keyring
kubectl exec deployment/example-galaxy-api -- gpg -k joe@foo.bar 2>/dev/null

# check if the the gpg key is in the worker's keyring
kubectl exec deployment/example-galaxy-worker -- gpg -k joe@foo.bar 2>/dev/null

