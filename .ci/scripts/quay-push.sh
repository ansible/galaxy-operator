#!/bin/bash -e
#!/usr/bin/env bash

# quay-push.sh: Push (Upload) image to quay.
# Image must be already tagged.

# TODO: These are already hardcoded in .travis.yml for the build task
#
# Ansible is an organization (not an individual user account) on Quay:
# https://quay.io/organization/ansible
# For test publishes, one can override this to any org or user.
QUAY_PROJECT_NAME=${QUAY_PROJECT_NAME:-ansible}
# The image name, AKA the Quay repo
QUAY_REPO_NAME=${QUAY_REPO_NAME:-galaxy-operator}
# The image tag
QUAY_IMAGE_TAG=${QUAY_IMAGE_TAG:-latest}

# TODO - Update with galaxy bot
QUAY_BOT_USERNAME=${QUAY_BOT_USERNAME:-pulp+github}

# Reference: https://adriankoshka.github.io/blog/posts/travis-and-quay/
echo "$QUAY_BOT_PASSWORD" | docker login -u "$QUAY_BOT_USERNAME" --password-stdin quay.io
docker push "quay.io/$QUAY_PROJECT_NAME/$QUAY_REPO_NAME:$QUAY_IMAGE_TAG"
