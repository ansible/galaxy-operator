#!/bin/bash -e
#!/usr/bin/env bash

# TODO - Update with galaxy bot
QUAY_BOT_USERNAME=${QUAY_BOT_USERNAME:-pulp+github}

echo "$QUAY_BOT_PASSWORD" | docker login -u "$QUAY_BOT_USERNAME" --password-stdin quay.io
make docker-push

export QUAY_IMAGE_TAG=v$(cat Makefile | grep "VERSION ?=" | cut -d' ' -f3)
echo $QUAY_IMAGE_TAG
docker tag quay.io/ansible/galaxy-operator:main quay.io/ansible/galaxy-operator:$QUAY_IMAGE_TAG
sudo -E $GITHUB_WORKSPACE/.ci/scripts/quay-push.sh

make bundle-build
make bundle-push

make catalog-build
make catalog-push
docker images
