#!/bin/bash -e
#!/usr/bin/env bash

if [[ "$CI_TEST_STORAGE" == "azure" ]]; then
  docker volume create azurite
  docker run -d -p 10000:10000 --name galaxy-azurite -v azurite:/data mcr.microsoft.com/azure-storage/azurite azurite-blob -l /data --skipApiVersionCheck --blobHost 0.0.0.0
  sleep 5
  AZURE_CONNECTION_STRING="DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://galaxy-azurite:10000/devstoreaccount1;"
  echo $(minikube ip)   galaxy-azurite | sudo tee -a /etc/hosts
  az storage container create --name galaxy-test --connection-string $AZURE_CONNECTION_STRING
elif [[ "$CI_TEST_STORAGE" == "s3" ]]; then
  export S3_ACCESS_KEY=AKIAIT2Z5TDYPX3ARJBA
  export S3_SECRET_KEY=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
  export S3_HOST=$(minikube ip)
  export S3_CONTAINER=galaxy_s3
  export SEAWEEDFS_IMAGE=chrislusf/seaweedfs:4.47@sha256:ce9e796f1fe6f06968f4c04bdaf8f678dad9c8acdfef3d244133d71bfa6bf882

  docker volume create seaweedfs
  docker run -d \
    -p 0.0.0.0:9000:8333 \
    --name "$S3_CONTAINER" \
    -e AWS_ACCESS_KEY_ID="$S3_ACCESS_KEY" \
    -e AWS_SECRET_ACCESS_KEY="$S3_SECRET_KEY" \
    -e S3_BUCKET=galaxy \
    -v seaweedfs:/data \
    "$SEAWEEDFS_IMAGE"

  while ! nc -z "$S3_HOST" 9000; do
    echo 'Wait SeaweedFS S3 endpoint to startup...' && sleep 0.1
  done
  while true; do
    S3_STATUS=$(curl -sS -o /dev/null -w "%{http_code}" "http://$S3_HOST:9000/" || true)
    if [[ "$S3_STATUS" == "200" || "$S3_STATUS" == "403" ]]; then
      break
    fi
    echo "Wait SeaweedFS S3 API to become ready (HTTP $S3_STATUS)..." && sleep 0.5
  done

  echo "$S3_HOST $S3_CONTAINER" | sudo tee -a /etc/hosts
  sed -i "s/$S3_CONTAINER/$S3_HOST/g" config/samples/galaxy_v1beta1_galaxy_cr.galaxy.s3.ci.yaml
fi
