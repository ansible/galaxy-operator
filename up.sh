#!/bin/bash

# up.sh: Deploy galaxy-operator to K8s

if command -v kubectl > /dev/null; then
  KUBECTL=$(command -v kubectl)
elif [ -x /usr/local/bin/kubectl ]; then
  KUBECTL=/usr/local/bin/kubectl
else
    echo "$0: ERROR 1: Cannot find kubectl"
fi

KUBE_ASSETS_DIR=${KUBE_ASSETS_DIR:-".ci/assets/kubernetes"}
OPERATOR_IMAGE=${OPERATOR_IMAGE:-"quay.io/ansible/galaxy-operator:main"}

echo "Make Deploy"
make deploy IMG=$OPERATOR_IMAGE
echo "Namespaces"
$KUBECTL get namespace
echo "Set context"
$KUBECTL config set-context --current --namespace=galaxy
echo "Get Deployment"
$KUBECTL get deployment

# TODO: Check if these should only ever be run once; or require
# special logic to update
# The Custom Resource (and any ConfigMaps) do not.
if [[ -e config/samples/galaxy_v1beta1_galaxy_cr.yaml ]]; then
  CUSTOM_RESOURCE=galaxy_v1beta1_galaxy_cr.yaml
elif [[ "$CI_TEST" == "true" && "$CI_TEST_IMAGE" == "minimal" ]]; then
  CUSTOM_RESOURCE=galaxy_v1beta1_galaxy_cr.ci.yaml
  echo "Will deploy admin password secret for testing ..."
  $KUBECTL apply -f $KUBE_ASSETS_DIR/galaxy-admin-password.secret.yaml
  echo "Will deploy container auth secret for testing ..."
  $KUBECTL apply -f $KUBE_ASSETS_DIR/galaxy-container-auth.secret.yaml
elif [[ "$CI_TEST" == "true" && "$CI_TEST_IMAGE" == "s6" ]]; then
  CUSTOM_RESOURCE=galaxy_v1beta1_galaxy_cr.s6.ci.yaml
  echo "Will deploy admin password secret for testing ..."
  $KUBECTL apply -f $KUBE_ASSETS_DIR/galaxy-admin-password.secret.yaml
  echo "Will deploy container auth secret for testing ..."
  $KUBECTL apply -f $KUBE_ASSETS_DIR/galaxy-container-auth.secret.yaml
elif [[ "$CI_TEST" == "aws" ]]; then
  CUSTOM_RESOURCE=galaxy_v1beta1_galaxy_cr.object_storage.aws.yaml
  echo "Will deploy admin password secret for testing ..."
  $KUBECTL apply -f $KUBE_ASSETS_DIR/galaxy-admin-password.secret.yaml
  echo "Will deploy object storage secret for testing ..."
  $KUBECTL apply -f $KUBE_ASSETS_DIR/galaxy-object-storage.aws.secret.yaml
elif [[ "$CI_TEST" == "azure" ]]; then
  CUSTOM_RESOURCE=galaxy_v1beta1_galaxy_cr.object_storage.azure.yaml
  echo "Will deploy admin password secret for testing ..."
  $KUBECTL apply -f $KUBE_ASSETS_DIR/galaxy-admin-password.secret.yaml
  echo "Will deploy object storage secret for testing ..."
  $KUBECTL apply -f $KUBE_ASSETS_DIR/galaxy-object-storage.azure.secret.yaml
elif [[ "$CI_TEST_STORAGE" == "azure" ]]; then
  echo "Will deploy object storage secret for testing ..."
  $KUBECTL apply -f $KUBE_ASSETS_DIR/galaxy-object-storage.azure.secret.yaml
  CUSTOM_RESOURCE=galaxy_v1beta1_galaxy_cr.galaxy.azure.ci.yaml
  echo "Will deploy admin password secret for testing ..."
  $KUBECTL apply -f $KUBE_ASSETS_DIR/galaxy-admin-password.secret.yaml
  echo "Will deploy container auth secret for testing ..."
  $KUBECTL apply -f $KUBE_ASSETS_DIR/galaxy-container-auth.secret.yaml
elif [[ "$CI_TEST_STORAGE" == "s3" ]]; then
  echo "Will deploy object storage secret for testing ..."
  $KUBECTL apply -f $KUBE_ASSETS_DIR/galaxy-object-storage.aws.secret.yaml
  CUSTOM_RESOURCE=galaxy_v1beta1_galaxy_cr.galaxy.s3.ci.yaml
  echo "Will deploy admin password secret for testing ..."
  $KUBECTL apply -f $KUBE_ASSETS_DIR/galaxy-admin-password.secret.yaml
  echo "Will deploy container auth secret for testing ..."
  $KUBECTL apply -f $KUBE_ASSETS_DIR/galaxy-container-auth.secret.yaml
elif [[ "$CI_TEST" == "galaxy" && "$CI_TEST_IMAGE" == "s6" ]]; then
  CUSTOM_RESOURCE=galaxy_v1beta1_galaxy_cr.galaxy.s6.ci.yaml
  echo "Will deploy admin password secret for testing ..."
  $KUBECTL apply -f $KUBE_ASSETS_DIR/galaxy-admin-password.secret.yaml
  echo "Will deploy signing secret for testing ..."
  $KUBECTL apply -f $KUBE_ASSETS_DIR/galaxy_sign.secret.yaml
  $KUBECTL apply -f $KUBE_ASSETS_DIR/signing_scripts.configmap.yaml
elif [[ "$CI_TEST" == "galaxy" ]]; then
  CUSTOM_RESOURCE=galaxy_v1beta1_galaxy_cr.galaxy.ci.yaml
  echo "Will deploy admin password secret for testing ..."
  $KUBECTL apply -f $KUBE_ASSETS_DIR/galaxy-admin-password.secret.yaml
  echo "Will deploy signing secret for testing ..."
  $KUBECTL apply -f $KUBE_ASSETS_DIR/galaxy_sign.secret.yaml
  $KUBECTL apply -f $KUBE_ASSETS_DIR/signing_scripts.configmap.yaml
elif [[ "$CI_TEST" == "galaxy-container" ]]; then
  CUSTOM_RESOURCE=galaxy_v1beta1_galaxy_cr.galaxy.yaml
  echo "Will deploy admin password secret for testing ..."
  $KUBECTL apply -f $KUBE_ASSETS_DIR/galaxy-admin-password.secret.yaml
  echo "Will deploy container auth secret for testing ..."
  $KUBECTL apply -f $KUBE_ASSETS_DIR/galaxy-container-auth.secret.yaml
elif [[ "$(hostname)" == "galaxy-demo"* ]]; then
  CUSTOM_RESOURCE=galaxy_v1beta1_galaxy_cr.galaxy-demo.yaml
else
  CUSTOM_RESOURCE=galaxy_v1beta1_galaxy_cr.default.yaml
fi
echo "Will deploy config Custom Resource config/samples/$CUSTOM_RESOURCE"
$KUBECTL apply -f config/samples/$CUSTOM_RESOURCE
