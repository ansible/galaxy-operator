# Development Guide

There are development yaml examples in the [`dev/`](../dev) directory and Makefile targets that can be used to build, deploy and test changes made to the galaxy operator.

Run `make help` to see all available targets and options.


## Prerequisites

You will need to have the following tools installed:

* [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
* [podman](https://podman.io/docs/installation) or [docker](https://docs.docker.com/get-docker/)
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [oc](https://docs.openshift.com/container-platform/4.11/cli_reference/openshift_cli/getting-started-cli.html) (if using OpenShift)

You will also need a container registry account. This guide uses [quay.io](https://quay.io), but any container registry will work.


## Registry Setup

1. Go to [quay.io](https://quay.io) and create a repository named `galaxy-operator` under your username.
2. Login at the CLI:
```sh
podman login quay.io
```

> **Note**: The first time you run `make up`, it will create quay.io repos on your fork. You will need to either make those public or create a global pull secret on your cluster.


## Build and Deploy

Make sure you are logged into your cluster (`oc login` or `kubectl` configured), then run:

```sh
QUAY_USER=username make up
```

This will:
1. Login to container registries
2. Create the target namespace
3. Build the operator image and push it to your registry
4. Deploy the operator via kustomize
5. Generate a GPG signing key and create the signing secret and scripts configmap
6. Create a dev Galaxy instance

About 5 minutes after the deployment completes, you will have a fully functional Galaxy deployment.

### Customization Options

| Variable | Default | Description |
|----------|---------|-------------|
| `QUAY_USER` | _(required)_ | Your quay.io username |
| `NAMESPACE` | `galaxy` | Target namespace |
| `DEV_TAG` | `dev` | Image tag for dev builds |
| `CONTAINER_TOOL` | `podman` | Container engine (`podman` or `docker`) |
| `PLATFORM` | _(auto-detected)_ | Target platform (e.g., `linux/amd64`) |
| `MULTI_ARCH` | `false` | Build multi-arch image (`linux/arm64,linux/amd64`) |
| `DEV_IMG` | `quay.io/<QUAY_USER>/galaxy-operator` | Override full image path (skips QUAY_USER) |
| `BUILD_IMAGE` | `true` | Set to `false` to skip image build (use existing image) |
| `CREATE_CR` | `true` | Set to `false` to skip creating the dev Galaxy instance |
| `CREATE_SECRETS` | `true` | Set to `false` to skip creating dev secrets |
| `IMAGE_PULL_POLICY` | `Always` | Set to `Never` for local builds without push |
| `BUILD_ARGS` | _(empty)_ | Extra args passed to container build (e.g., `--no-cache`) |
| `DEV_CR` | `dev/cr-examples/galaxy.cr.yml` | Path to the dev CR to apply |
| `PODMAN_CONNECTION` | _(empty)_ | Remote podman connection name |

Examples:

```bash
# Use a specific namespace and tag
QUAY_USER=username NAMESPACE=galaxy DEV_TAG=mytag make up

# Use docker instead of podman
CONTAINER_TOOL=docker QUAY_USER=username make up

# Build for a specific platform (e.g., when on ARM building for x86)
PLATFORM=linux/amd64 QUAY_USER=username make up

# Deploy without building (use an existing image)
BUILD_IMAGE=false DEV_IMG=quay.io/myuser/galaxy-operator:latest make up
```

### Accessing the Deployment

On **OpenShift**:
```sh
oc get route
```

On **k8s with ingress**:
```sh
kubectl get ing
```

On **k8s with nodeport**:
```sh
kubectl get svc
```
The URL is then `http://<Node-IP>:<NodePort>`.

### Default Credentials

To get the admin password:

```sh
oc get secret admin-password-secret -o jsonpath={.data.password} | base64 --decode
```


## Clean up

To tear down your development deployment:

```sh
make down
```

### Teardown Options

| Variable | Default | Description |
|----------|---------|-------------|
| `KEEP_NAMESPACE` | `false` | Set to `true` to keep the namespace for reuse |
| `DELETE_PVCS` | `true` | Set to `false` to preserve PersistentVolumeClaims |
| `DELETE_SECRETS` | `true` | Set to `false` to preserve secrets |

Examples:

```bash
# Keep the namespace for faster redeploy
KEEP_NAMESPACE=true make down

# Keep PVCs (preserve database data between deploys)
DELETE_PVCS=false make down
```


## Testing

### Linting

Run linting checks (required for all PRs):

```sh
make lint
```


## Bundle Generation

If you have the Operator Lifecycle Manager (OLM) installed, you can generate and deploy an operator bundle:

```bash
# Generate bundle manifests and validate
make bundle

# Build and push the bundle image
make bundle-build bundle-push

# Build and push a catalog image
make catalog-build catalog-push
```

After pushing the catalog, create a `CatalogSource` in your cluster pointing to the catalog image. Once the CatalogSource is in a READY state, the operator will be available in OperatorHub.
