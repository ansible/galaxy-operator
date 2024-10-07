#!/bin/bash
# Galaxy Operator ansible-down.sh

# -- Usage
#   NAMESPACE=galaxy ./ansible-down.sh
#
# -- User Environment Variables
# export NAMESPACE=testme                   # Namespace to deploy to
# export QUAY_USER=chadams                  # Quay.io username to push operator image to


# -- Variables
TAG=${TAG:-dev}
IMG=quay.io/$QUAY_USER/galaxy-operator:$TAG

if [ -z "$QUAY_USER" ]; then
  echo "Error: QUAY_USER env variable is not set."
  echo "  export QUAY_USER=developer"

  exit 1
fi
if [ -z "$NAMESPACE" ]; then
  echo "Error: NAMESPACE env variable is not set. Run the following with your namespace:"
  echo "  export NAMESPACE=developer"
  exit 1
fi


# Delete Custom Resources
oc delete galaxyrestore --all -n $NAMESPACE
oc delete galaxybackup --all -n $NAMESPACE
oc delete galaxy --all -n $NAMESPACE

# Delete Secrets
oc delete secrets --all -n $NAMESPACE

# Delete old operator deployment
oc delete deployment galaxy-operator-controller-manager -n $NAMESPACE

# Deploy Operator
make undeploy IMG=$IMG NAMESPACE=$NAMESPACE

# Delete Azurite Storage
oc delete -f hacking/azurite/azurite.yaml

# Delete tls and ca certs
rm -rf ./hacking/ca-cert/*
rm -rf ./hacking/tls-azurite/*
rm -rf ./hacking/tls-galaxy/*

# Remove PVCs
oc delete pvc --all -n $NAMESPACE

