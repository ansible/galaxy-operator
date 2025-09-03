#!/bin/bash
# Galaxy-Operator ansible-up.sh

# -- Usage
#   NAMESPACE=gateway TAG=dev QUAY_USER=developer ./ansible-up.sh
#
# -- User Environment Variables
# export NAMESPACE=testme                   # Namespace to deploy to
# export QUAY_USER=developer                # Quay.io username to push operator image to


# -- Variables
TAG=${TAG:-dev}

DEV_CR=${DEV_CR:-dev/cr-examples/galaxy.cr.yml}
PULL_SECRET_FILE=${PULL_SECRET_FILE:-hacking/pull-secret.yml}

IMG=${IMG:-"quay.io/$QUAY_USER/galaxy-operator:$TAG"}
KUBE_APPLY="kubectl apply -n $NAMESPACE -f"

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


# -- Prepare

# Set imagePullPolicy to Always

# Set default in manifest and crd files
files=(
    config/manager/manager.yaml
)
for file in "${files[@]}"; do
  if ! grep -qF 'imagePullPolicy:' ${file}; then
    sed -i -e "/image: controller:latest/a \\
        imagePullPolicy: Always" ${file};
  fi
done

# Set imagePullPolicy to Always
files=(
    config/manager/manager.yaml
)
for file in "${files[@]}"; do
  if grep -qF 'imagePullPolicy: IfNotPresent' ${file}; then
    sed -i -e "s|imagePullPolicy: IfNotPresent|imagePullPolicy: Always|g"  ${file};
  fi
done


# -- Wait for existing project to be deleted

# Function to check if the namespace is in terminating state
is_namespace_terminating() {
    kubectl get namespace $NAMESPACE 2>/dev/null | grep -q 'Terminating'
    return $?
}

# Check if the namespace exists and is in terminating state
if kubectl get namespace $NAMESPACE 2>/dev/null; then
    echo "Namespace $NAMESPACE exists."

    if is_namespace_terminating; then
        echo "Namespace $NAMESPACE is in terminating state. Waiting for it to be fully terminated..."
        while is_namespace_terminating; do
            sleep 5
        done
        echo "Namespace $NAMESPACE has been terminated."
    fi
fi


# -- Create namespace
# oc new-project $NAMESPACE
kubectl create namespace $NAMESPACE
kubectl config set-context --current --namespace=$NAMESPACE

# -- Delete old operator deployment
kubectl delete deployment galaxy-operator-controller-manager

# -- Create Pull Secret
if [ -f "$PULL_SECRET_FILE" ]; then
    $KUBE_APPLY $PULL_SECRET_FILE
else
    kubectl create secret generic redhat-operators-pull-secret --from-file=.dockerconfigjson=$HOME/.docker/config.json --type=kubernetes.io/dockerconfigjson
fi

# -- Create Secrets for data migration if desired
$KUBE_APPLY dev/admin-password-secret.yml


# -- Build & Push Operator Image
make docker-build docker-push IMG=$IMG

# -- Deploy Pulp Operator
echo "Make Deploy"
make deploy IMG=$IMG NAMESPACE=$NAMESPACE

# -- CI assets
# $KUBE_APPLY .ci/assets/kubernetes/galaxy_sign.secret.yaml
# $KUBE_APPLY .ci/assets/kubernetes/signing_scripts.configmap.yaml
# $KUBE_APPLY .ci/assets/kubernetes/pulp-admin-password.secret.yaml
# sed -i '/file_storage_access_mode:/c\  file_storage_access_mode: ReadWriteOnce' config/samples/pulpproject_v1beta1_pulp_cr.galaxy.ci.yaml
# $KUBE_APPLY config/samples/pulpproject_v1beta1_pulp_cr.galaxy.ci.yaml # CI CR


# Signing Configurations
$KUBE_APPLY .ci/assets/kubernetes/galaxy_sign.secret.yaml
$KUBE_APPLY .ci/assets/kubernetes/signing_scripts.configmap.yaml

echo "Create Galaxy Custom Resource Object"
$KUBE_APPLY $DEV_CR



