# Galaxy Operator Storage Configuration

This document provides comprehensive guidance for configuring storage backends in Galaxy Operator deployments. Galaxy Operator supports multiple storage configurations to meet different deployment requirements and infrastructure constraints.

## Overview

Galaxy Operator supports several storage backend options for persisting data:

- **File Storage** - Traditional file system storage using Kubernetes volumes
- **Amazon S3** - S3-compatible object storage
- **Azure Blob Storage** - Microsoft Azure object storage
- **S3-Compatible Services** - Alternative object storage providers with S3-compatible APIs

**Important**: Only one storage type should be configured per Galaxy deployment. Attempting to configure multiple storage types simultaneously will cause operator execution to fail.

## File Storage Configuration

File storage uses Kubernetes persistent volumes to store Galaxy data on the file system.

### Storage Class Configuration

Use Storage Classes for automatic PVC provisioning:

```yaml
apiVersion: galaxy.ansible.com/v1beta1
kind: Galaxy
metadata:
  name: galaxy-instance
spec:
  file_storage_storage_class: fast-ssd
  file_storage_size: "100Gi"
  file_storage_access_mode: "ReadWriteMany"
  postgres_storage_class: db-storage
  postgres_storage_requirements:
    requests:
      storage: 50Gi
  postgres_resource_requirements:
    requests:
      cpu: 500m
      memory: 2Gi
    limits:
      cpu: '1'
      memory: 4Gi
  cache:
    redis_storage_class: cache-storage
    redis_storage_size: "10Gi"
```

Key parameters:

- `file_storage_storage_class` - Storage class name for Galaxy core pods
- `file_storage_size` - Size of the persistent volume
- `file_storage_access_mode` - Access mode (typically `ReadWriteMany` for multi-pod access)
- `postgres_storage_class` - Storage class name for PostgreSQL database
- `postgres_storage_requirements` - PostgreSQL storage size requirements
- `postgres_resource_requirements` - PostgreSQL CPU and memory requirements

#### Why ReadWriteMany is Essential for Galaxy File Storage

**ReadWriteMany** access mode is crucial for Galaxy deployments because the operator creates multiple pods that require concurrent access to the same storage:

**Multi-Pod Architecture Requirements:**
- **Galaxy API servers** - Multiple replicas for high availability
- **Galaxy workers** - Background task processors that need shared file access
- **Galaxy content service** - Handles collection and container storage
- **Galaxy web UI** - May need access to static files and uploads

**Shared Data Access Patterns:**
All Galaxy components need to:
- Read shared collections and artifacts stored by other pods
- Write new content that other pods must immediately access
- Access user uploads across different service endpoints
- Share configuration files and static assets

**Scalability and Operational Benefits:**
- **Horizontal scaling** - Add more API/worker pods without storage bottlenecks
- **Load distribution** - Multiple pods can serve content simultaneously
- **Zero-downtime deployments** - New pods can access existing data immediately
- **Backup consistency** - All pods see the same data state
- **Development flexibility** - Easy to add new service types that need file access

**Important:** Using `ReadWriteOnce` would limit you to a single pod having write access, eliminating Galaxy's ability to scale horizontally and provide high availability - essential requirements for production deployments.

## Object Storage Configuration

Object storage backends provide scalable, cloud-native storage solutions for Galaxy deployments.

### Amazon S3 Configuration

Configure S3 storage using a Kubernetes Secret:

1. Create the S3 credentials secret:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: galaxy-s3-secret
type: Opaque
stringData:
  s3-access-key-id: "YOUR_ACCESS_KEY"
  s3-secret-access-key: "YOUR_SECRET_KEY"
  s3-bucket-name: "galaxy-storage"
  s3-region: "us-west-2"
  s3-endpoint: "https://s3.amazonaws.com"  # Optional, defaults to AWS
```

2. Reference the secret in your Galaxy CR:

```yaml
apiVersion: galaxy.ansible.com/v1beta1
kind: Galaxy
metadata:
  name: galaxy-instance
spec:
  object_storage_s3_secret: galaxy-s3-secret
  storage_type: s3
```

#### S3 Configuration Parameters

The operator automatically configures the following Django storage settings:

```python
STORAGES = {
    "default": {
        "BACKEND": "storages.backends.s3boto3.S3Boto3Storage",
        "OPTIONS": {
            "bucket_name": "<from secret>",
            "access_key": "<from secret>",
            "secret_key": "<from secret>",
            "region_name": "<from secret>",
            "endpoint_url": "<from secret>",
            "signature_version": "s3v4",
            "addressing_style": "path",
        },
    },
}
MEDIA_ROOT = ""
```

### Azure Blob Storage Configuration

Configure Azure storage using a Kubernetes Secret:

1. Create the Azure credentials secret:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: galaxy-azure-secret
type: Opaque
stringData:
  azure-account-name: "yourstorageaccount"
  azure-account-key: "YOUR_ACCOUNT_KEY"
  azure-container: "galaxy-container"
  azure-container-path: "galaxy/"
  azure-connection-string: "DefaultEndpointsProtocol=https;AccountName=..."  # Optional
```

2. Reference the secret in your Galaxy CR:

```yaml
apiVersion: galaxy.ansible.com/v1beta1
kind: Galaxy
metadata:
  name: galaxy-instance
spec:
  object_storage_azure_secret: galaxy-azure-secret
  storage_type: azure
```

#### Azure Configuration Parameters

The operator automatically configures the following Django storage settings:

```python
STORAGES = {
    "default": {
        "BACKEND": "storages.backends.azure_storage.AzureStorage",
        "OPTIONS": {
            "connection_string": "<from secret>",
            "location": "<from secret>",
            "account_name": "<from secret>",
            "azure_container": "<from secret>",
            "account_key": "<from secret>",
            "expiration_secs": 60,
            "overwrite_files": True,
        },
    },
}
MEDIA_ROOT = ""
```

## S3-Compatible Storage Providers

Galaxy Operator supports S3-compatible storage services through the same S3 configuration mechanism. Popular S3-compatible providers include:

- **Backblaze B2**
- **Cloudflare R2**
- **Digital Ocean Spaces**
- **Oracle Cloud Storage**
- **Scaleway Object Storage**
- **MinIO**

### Configuration for S3-Compatible Services

Use the S3 secret format with provider-specific endpoints:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: galaxy-s3-compatible-secret
type: Opaque
stringData:
  s3-access-key-id: "YOUR_ACCESS_KEY"
  s3-secret-access-key: "YOUR_SECRET_KEY"
  s3-bucket-name: "galaxy-storage"
  s3-region: "us-east-1"  # May vary by provider
  s3-endpoint: "https://s3.us-east-005.backblazeb2.com"  # Provider-specific endpoint
```

### Provider-Specific Examples

#### Backblaze B2

```yaml
stringData:
  s3-endpoint: "https://s3.us-west-002.backblazeb2.com"
  s3-region: "us-west-002"
```

#### Digital Ocean Spaces

```yaml
stringData:
  s3-endpoint: "https://nyc3.digitaloceanspaces.com"
  s3-region: "nyc3"
```

#### MinIO

```yaml
stringData:
  s3-endpoint: "https://minio.example.com"
  s3-region: "us-east-1"
```
