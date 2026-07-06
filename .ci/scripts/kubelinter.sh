#!/usr/bin/env bash
# coding=utf-8

set -euo pipefail

KUBE_LINTER_VERSION="v0.8.3"
TARGET="kube-linter-linux-${KUBE_LINTER_VERSION}.tar.gz"
LOCATION="https://github.com/stackrox/kube-linter/releases/download/${KUBE_LINTER_VERSION}/kube-linter-linux.tar.gz"

if [ ! -e "$TARGET" ]; then
  curl --silent --show-error --fail --location --output "$TARGET" "$LOCATION"
  tar -xf "$TARGET"
fi
mkdir -p lint
sudo -E kubectl get galaxy,galaxybackup,galaxyrestore,pvc,configmap,serviceaccount,secret,networkpolicy,ingress,service,deployment,statefulset,hpa,job,cronjob -o yaml > ./lint/k8s-all.yaml
./kube-linter lint ./lint --config .ci/assets/kubernetes/.kube-linter.yaml
