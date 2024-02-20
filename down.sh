#!/bin/bash

# down.sh: Delete galaxy-operator from K8s

# CentOS 7 /etc/sudoers , and non-interactive shells (vagrant provisions)
# do not include /usr/local/bin , Which k3s installs to.
# But we do not want to break other possible kubectl implementations by
# hardcoding /usr/local/bin/kubectl .
# And this entire script may be run with sudo.
# So if kubectl is not in the PATH, assume /usr/local/bin/kubectl .
if command -v kubectl > /dev/null; then
  KUBECTL=$(command -v kubectl)
elif [ -x /usr/local/bin/kubectl ]; then
  KUBECTL=/usr/local/bin/kubectl
else
    echo "$0: ERROR 1: Cannot find kubectl"
fi

make undeploy

# It doesn't matter which cr we specify; the metadata up top is the same.
$KUBECTL delete -f config/samples/galaxy_v1beta1_galaxy_cr.default.yaml
$KUBECTL delete -f config/crd/bases/galaxy_v1beta1_galaxy_crd.yaml
$KUBECTL delete -f config/crd/bases/galaxy_v1beta1_galaxybackup_crd.yaml
$KUBECTL delete -f config/crd/bases/galaxy_v1beta1_galaxyrestore_crd.yaml

if [[ "$CI_TEST" == "true" ]]; then
  $KUBECTL delete -f .ci/assets/kubernetes/galaxy-admin-password.secret.yaml
fi
