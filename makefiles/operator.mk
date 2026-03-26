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
operator-up: _operator-build-and-push _operator-deploy _operator-post-deploy ## Galaxy-specific deploy

.PHONY: _operator-build-and-push
_operator-build-and-push:
	@if [ "$(BUILD_IMAGE)" != "true" ]; then \
		echo "Skipping image build (BUILD_IMAGE=false)"; \
		exit 0; \
	fi; \
	$(MAKE) dev-build; \
	echo "Pushing $(DEV_IMG):$(DEV_TAG)..."; \
	$(_CONTAINER_CMD) push $(DEV_IMG):$(DEV_TAG)

.PHONY: _operator-deploy
_operator-deploy: kustomize
	@$(MAKE) pre-deploy-cleanup
	@echo "Deploying operator via kustomize..."
	@cd config/default && $(KUSTOMIZE) edit set namespace $(NAMESPACE)
	@$(MAKE) deploy IMG=$(DEV_IMG):$(DEV_TAG)

.PHONY: _operator-post-deploy
_operator-post-deploy:
	@echo "Waiting for operator pods to be ready..."
	@ATTEMPTS=0; \
	while [ $$ATTEMPTS -lt 30 ]; do \
		READY=$$($(KUBECTL) get deployment $(DEPLOYMENT_NAME) -n $(NAMESPACE) \
			-o jsonpath='{.status.readyReplicas}' 2>/dev/null); \
		DESIRED=$$($(KUBECTL) get deployment $(DEPLOYMENT_NAME) -n $(NAMESPACE) \
			-o jsonpath='{.status.replicas}' 2>/dev/null); \
		if [ -n "$$READY" ] && [ -n "$$DESIRED" ] && [ "$$READY" = "$$DESIRED" ] && [ "$$READY" -gt 0 ]; then \
			echo "All pods ready ($$READY/$$DESIRED)."; \
			break; \
		fi; \
		echo "Pods not ready ($$READY/$$DESIRED). Waiting..."; \
		ATTEMPTS=$$((ATTEMPTS + 1)); \
		sleep 10; \
	done; \
	if [ $$ATTEMPTS -ge 30 ]; then \
		echo "ERROR: Timed out waiting for operator pods to be ready (5 minutes)." >&2; \
		exit 1; \
	fi
	@# Create signing resources
	@if [ "$(CREATE_SECRETS)" = "true" ]; then \
		$(MAKE) _operator-create-signing-resources; \
	fi
	@# Apply custom configs (secrets, configmaps, etc.)
	@$(MAKE) _apply-custom-config
	@# Apply dev CR
	@if [ "$(CREATE_CR)" = "true" ] && [ -f "$(DEV_CR)" ]; then \
		echo "Applying dev CR: $(DEV_CR)"; \
		$(KUBECTL) apply -n $(NAMESPACE) -f $(DEV_CR); \
	fi

.PHONY: _operator-create-signing-resources
_operator-create-signing-resources: ## Create signing secret and scripts configmap
	@echo "Generating GPG key for signing service..."
	@GPG_HOME=$$(mktemp -d); \
	gpg --homedir $$GPG_HOME --batch --gen-key <<< "$$(printf '%s\n' \
		'%no-protection' \
		'Key-Type: RSA' \
		'Key-Length: 2048' \
		'Name-Real: Galaxy Dev Signing' \
		'Name-Email: galaxy-dev@example.com' \
		'%commit')"; \
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
