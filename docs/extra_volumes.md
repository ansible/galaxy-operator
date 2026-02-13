# Extra Volumes Configuration

The Galaxy operator supports mounting additional volumes in Galaxy components using the `extra_volumes` feature, following the same pattern as the AWX operator.

## Overview

The extra volumes feature uses component-specific fields for both volume definitions and mounting:

## Supported Components

Each component has its own pair of fields for defining volumes and mounting them:

### API Component
- `api_extra_volumes` - Define volumes for Galaxy API pods
- `api_extra_volume_mounts` - Mount volumes in Galaxy API containers

### Content Component
- `content_extra_volumes` - Define volumes for Galaxy Content pods
- `content_extra_volume_mounts` - Mount volumes in Galaxy Content containers

### Worker Component
- `worker_extra_volumes` - Define volumes for Galaxy Worker pods
- `worker_extra_volume_mounts` - Mount volumes in Galaxy Worker containers

## Configuration

### Basic Example

```yaml
apiVersion: galaxy.ansible.com/v1beta1
kind: Galaxy
metadata:
  name: galaxy-with-custom-volumes
spec:
  # Define volumes for API component
  api_extra_volumes: |
    - name: custom-config
      configMap:
        name: my-custom-config
    - name: api-shared-storage
      persistentVolumeClaim:
        claimName: api-shared-pvc

  # Mount volumes in API containers
  api_extra_volume_mounts: |
    - name: custom-config
      mountPath: /etc/galaxy/custom
      readOnly: true
    - name: api-shared-storage
      mountPath: /var/shared

  # Define volumes for worker component
  worker_extra_volumes: |
    - name: worker-temp-storage
      emptyDir:
        sizeLimit: 5Gi

  # Mount volumes in worker containers
  worker_extra_volume_mounts: |
    - name: worker-temp-storage
      mountPath: /tmp/worker
```

### Supported Volume Types

The component-specific `*_extra_volumes` fields accept standard Kubernetes volume definitions:

#### ConfigMap

```yaml
api_extra_volumes: |
  - name: app-config
    configMap:
      name: galaxy-config
      items:
        - key: config.yaml
          path: app.yaml
```

#### Secret

```yaml
content_extra_volumes: |
  - name: ssl-certs
    secret:
      secretName: tls-certificates
      defaultMode: 0600
```

#### PersistentVolumeClaim

```yaml
worker_extra_volumes: |
  - name: data-storage
    persistentVolumeClaim:
      claimName: galaxy-data-pvc
```

#### EmptyDir

```yaml
api_extra_volumes: |
  - name: temp-storage
    emptyDir:
      sizeLimit: 1Gi
```

#### HostPath (use with caution)

```yaml
worker_extra_volumes: |
  - name: host-logs
    hostPath:
      path: /var/log/galaxy
      type: DirectoryOrCreate
```

### Volume Mount Options

Each volume mount supports standard Kubernetes volumeMount options:

```yaml
api_extra_volume_mounts: |
  - name: custom-config
    mountPath: /etc/galaxy/custom    # Required: where to mount
    subPath: config.yaml             # Optional: specific file/directory
    readOnly: true                   # Optional: read-only mount (default: false)
```

## Use Cases

### Custom Configuration Files

Mount custom configuration files from ConfigMaps:

```yaml
api_extra_volumes: |
  - name: galaxy-settings
    configMap:
      name: custom-galaxy-settings

api_extra_volume_mounts: |
  - name: galaxy-settings
    mountPath: /etc/pulp/custom-settings.py
    subPath: settings.py
    readOnly: true
```

### SSL Certificates

Mount custom SSL certificates from Secrets:

```yaml
api_extra_volumes: |
  - name: custom-certs
    secret:
      secretName: galaxy-tls-certs

api_extra_volume_mounts: |
  - name: custom-certs
    mountPath: /etc/ssl/certs/custom
    readOnly: true
```

### Component-Specific Storage

Mount different storage for different components:

```yaml
# API component gets config storage
api_extra_volumes: |
  - name: api-config
    persistentVolumeClaim:
      claimName: galaxy-api-config-pvc

api_extra_volume_mounts: |
  - name: api-config
    mountPath: /var/api-config

# Content component gets media storage
content_extra_volumes: |
  - name: media-storage
    persistentVolumeClaim:
      claimName: galaxy-media-pvc

content_extra_volume_mounts: |
  - name: media-storage
    mountPath: /var/media

# Worker component gets temp processing storage
worker_extra_volumes: |
  - name: temp-processing
    emptyDir:
      sizeLimit: 5Gi

worker_extra_volume_mounts: |
  - name: temp-processing
    mountPath: /tmp/processing
```

## Important Notes

1. **YAML Format**: The volume definitions use YAML format within the string fields
2. **Component Targeting**: Each component has its own `*_extra_volume_mounts` field
3. **Init Containers**: Extra volumes are also mounted in init containers for each component
4. **Compatibility**: This feature follows the AWX operator pattern for consistency
5. **Validation**: Ensure proper YAML syntax and valid Kubernetes volume/volumeMount specifications

## Example Complete Configuration

See `config/samples/galaxy_v1beta1_galaxy_cr.extra_volumes.yaml` for a complete working example.
