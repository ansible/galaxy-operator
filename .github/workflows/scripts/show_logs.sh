#!/bin/bash -e
#!/usr/bin/env bash

sudo -E docker images

KUBE="minikube"
if [[ "$1" == "--kind" ]] || [[ "$1" == "-k" ]]; then
  KUBE="kind"
  echo "Running $KUBE"
  kind export kubeconfig --name osdk-test
  sudo -E kubectl config set-context --current --namespace=osdk-test
  sudo -E kubectl port-forward service/example-galaxy-web-svc 24880:24880 &
  echo ::group::KIND_LOGS
  mkdir -p logs
  kind export logs --name osdk-test ./logs
  cd logs
  cat docker-info.txt
  cat kind-version.txt
  cd osdk-test-control-plane
  cat alternatives.log
  cat containerd.log
  cat inspect.json | jq
  cat journal.log
  cat kubelet.log
  cat kubernetes-version.txt
  echo ::endgroup::
fi

sudo -E kubectl get pods -o wide
sudo -E kubectl get pods -o go-template='{{range .items}} {{.metadata.name}} {{range .status.containerStatuses}} {{.lastState.terminated.exitCode}} {{end}}{{"\n"}} {{end}}'
sudo -E kubectl get deployments

if [[ "$KUBE" == "minikube" ]]; then
  echo ::group::METRICS
  sudo -E kubectl top pods || true
  sudo -E kubectl describe node minikube || true
  echo ::endgroup::
  echo ::group::MINIKUBE_LOGS
  minikube logs -n 10000
  echo ::endgroup::
fi

echo ::group::OPERATOR_LOGS
sudo -E kubectl logs -l app.kubernetes.io/name=galaxy-operator -c galaxy-operator --tail=10000
echo ::endgroup::

echo ::group::GALAXY_API_LOGS
sudo -E kubectl logs -l app.kubernetes.io/name=galaxy-api --tail=10000 || true
echo ::endgroup::

echo ::group::GALAXY_CONTENT_LOGS
sudo -E kubectl logs -l app.kubernetes.io/name=galaxy-content --tail=10000 || true
echo ::endgroup::

echo ::group::GALAXY_WORKER_LOGS
sudo -E kubectl logs -l app.kubernetes.io/name=galaxy-worker --tail=10000 || true
echo ::endgroup::

echo ::group::GALAXY_WEB_LOGS
sudo -E kubectl logs -l app.kubernetes.io/name=nginx --tail=10000 || true
echo ::endgroup::

echo ::group::POSTGRES
sudo -E kubectl logs -l app.kubernetes.io/name=postgres --tail=10000 || true
echo ::endgroup::

echo ::group::EVENTS
sudo -E kubectl get events --sort-by='.metadata.creationTimestamp' || true
echo ::endgroup::

echo ::group::OBJECTS
sudo -E kubectl get galaxy,galaxybackup,galaxyrestore,pvc,configmap,serviceaccount,secret,networkpolicy,ingress,service,deployment,statefulset,hpa,job,cronjob -o yaml
echo ::endgroup::

echo "Content endpoint"
http HEAD http://localhost:24880/galaxy/content/ || true
echo "Status endpoint"
http --follow --timeout 30 --check-status --pretty format --print hb http://localhost:24880/api/galaxy/pulp/api/v3/status/ || true
