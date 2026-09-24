#!/bin/bash -e
#!/usr/bin/env bash

if [[ "$CI_TEST_DATABASE" == "external" ]]; then
  docker volume create postgresql
  docker run -d -p 5555:5432 --name postgresql -e POSTGRESQL_USER=galaxy -e POSTGRESQL_PASSWORD=galaxy -e POSTGRESQL_DATABASE=galaxy -v postgresql:/var/lib/pgsql/data quay.io/sclorg/postgresql-15-c9s:latest
  echo $(minikube ip)   galaxy-postgresql | sudo tee -a /etc/hosts
fi
