# operator.mk — Galaxy Operator specific targets and variables
#
# This file is NOT synced across repos. Each operator maintains its own.

#@ Operator Variables

VERSION ?= $(shell git describe --tags 2>/dev/null || echo 0.0.1)
IMAGE_TAG_BASE ?= quay.io/ansible/galaxy-operator
NAMESPACE ?= galaxy
DEPLOYMENT_NAME ?= galaxy-operator-controller-manager
CHANNELS = "alpha"
DEFAULT_CHANNEL = "alpha"

# Dev CR to apply after deployment
DEV_CR ?= dev/cr-examples/galaxy.cr.yml

# Dev signing resources
DEV_SIGNING_SCRIPTS ?= dev/signing-scripts.configmap.yml

# Custom configs to apply during post-deploy (secrets, configmaps, etc.)
DEV_CUSTOM_CONFIG ?= dev/signing-scripts.configmap.yml

# Feature flags
BUILD_IMAGE ?= true
CREATE_CR ?= true
CREATE_SECRETS ?= true

# Teardown configuration
TEARDOWN_CR_KINDS ?= galaxy
TEARDOWN_BACKUP_KINDS ?= galaxybackup
TEARDOWN_RESTORE_KINDS ?= galaxyrestore
OLM_SUBSCRIPTIONS ?=

##@ Galaxy Operator

.PHONY: operator-up
operator-up: _operator-build-and-push _operator-deploy _operator-wait-ready _galaxy-create-signing-resources _operator-post-deploy ## Galaxy-specific deploy
	@:

.PHONY: _galaxy-create-signing-resources
_galaxy-create-signing-resources: ## Create signing secret and scripts configmap
	@if [ "$(CREATE_SECRETS)" != "true" ]; then exit 0; fi
	@echo "Generating GPG key for signing service..."
	@GPG_HOME=$$(mktemp -d); \
	printf '%s\n' \
		'%no-protection' \
		'Key-Type: RSA' \
		'Key-Length: 2048' \
		'Name-Real: Galaxy Dev Signing' \
		'Name-Email: galaxy-dev@example.com' \
		'%commit' | gpg --homedir $$GPG_HOME --batch --gen-key; \
	GPG_KEY=$$(gpg --homedir $$GPG_HOME --armor --export-secret-keys); \
	$(KUBECTL) create secret generic signing-galaxy \
		--from-literal=signing_service.gpg="$$GPG_KEY" \
		--namespace $(NAMESPACE) \
		--dry-run=client -o yaml | $(KUBECTL) apply -f -; \
	rm -rf $$GPG_HOME; \
	echo "Signing secret created."
	@if [ -f "$(DEV_SIGNING_SCRIPTS)" ]; then \
		echo "Creating signing scripts configmap..."; \
		$(KUBECTL) apply -n $(NAMESPACE) -f $(DEV_SIGNING_SCRIPTS); \
	fi

##@ Release

.PHONY: generate-operator-yaml
generate-operator-yaml: kustomize ## Generate operator.yaml with image tag $(VERSION)
	@cd config/manager && $(KUSTOMIZE) edit set image controller=quay.io/ansible/galaxy-operator:${VERSION}
	@$(KUSTOMIZE) build config/default > ./operator.yaml
	@echo "Generated operator.yaml with image tag $(VERSION)"
