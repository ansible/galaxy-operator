# Galaxy-Operator Build

Galaxy-Operator can be built and deployed locally for development and testing purposes.

For local development and testing we recommend using the latest version of [podman-desktop](https://podman-desktop.io/) which contains all the necessary tools to build and deploy galaxy-operator and galaxy-ng.

In our example we will use [minikube](https://minikube.sigs.k8s.io/docs/) with [podman](https://podman.io/) as the driver.

## 1. Create Kubernetes Cluster

To get started stand up a local Kubernetes cluster by creating a minikube cluster with the ingress addon enabled:

```
minikube start --driver=podman --cpus=4 --memory=8g --addons=ingress,ingress-dns
```
## 2. Build Galaxy-Operator
Clone the latest galaxy-operator code:
```
git clone https://github.com/ansible/galaxy-operator
```
Build the operator image:
```
(cd galaxy-operator && make build)
```
> (builds the operator image with podman):
```
podman build -t quay.io/ansible/galaxy-operator:0.15.0-26-g9ffb4ac .
...
COMMIT quay.io/ansible/galaxy-operator:0.15.0-26-g9ffb4ac
--> bc62ca90d408
Successfully tagged quay.io/ansible/galaxy-operator:0.15.0-26-g9ffb4ac
```
Confirm that the image is built and tagged:
```
podman images "galaxy-operator"
```

```                                 
REPOSITORY                          TAG                 IMAGE ID      CREATED        SIZE
quay.io/ansible/galaxy-operator     0.15.0-26-g9ffb4ac  0e8834256cdd  3 seconds ago  535 MB
```

## 2. Push Image to Kubernetes cluster
Save image:
```
podman image save quay.io/ansible/galaxy-operator:0.15.0-26-g9ffb4ac -o image.tar
```

Load image into minikube:
```
minikube image load image.tar
```

Confirm image is available to the cluster:
```
minikube image list | grep galaxy-operator
```

```
quay.io/ansible/galaxy-operator:0.15.0-26-g9ffb4ac
```

## 3. Deploy Galaxy-Operator
Deploy the operator image to the Kubernetes cluster:
```
(cd galaxy-operator && make deploy)
```

```
...
namespace/galaxy created
customresourcedefinition.apiextensions.k8s.io/galaxies.galaxy.ansible.com created
customresourcedefinition.apiextensions.k8s.io/galaxybackups.galaxy.ansible.com created
customresourcedefinition.apiextensions.k8s.io/galaxyrestores.galaxy.ansible.com created
serviceaccount/galaxy-operator-sa created
role.rbac.authorization.k8s.io/galaxy-operator-galaxy-operator-role created
role.rbac.authorization.k8s.io/galaxy-operator-leader-election-role created
role.rbac.authorization.k8s.io/galaxy-operator-proxy-role created
clusterrole.rbac.authorization.k8s.io/galaxy-operator-galaxy-operator-cluster-role created
clusterrole.rbac.authorization.k8s.io/galaxy-operator-metrics-reader created
rolebinding.rbac.authorization.k8s.io/galaxy-operator-galaxy-operator-rolebinding created
rolebinding.rbac.authorization.k8s.io/galaxy-operator-leader-election-rolebinding created
rolebinding.rbac.authorization.k8s.io/galaxy-operator-proxy-rolebinding created
clusterrolebinding.rbac.authorization.k8s.io/galaxy-operator-galaxy-operator-cluster-rolebinding created
configmap/galaxy-operator-galaxy-operator-config created
service/galaxy-operator-controller-manager-metrics-service created
deployment.apps/galaxy-operator-controller-manager created
```
Confirm that the operator is created:
```
kubectl get all -n galaxy
```
> (wait for everything to be running):

```
NAME                                                     READY   STATUS    RESTARTS   AGE
pod/galaxy-operator-controller-manager-d84cd6d4c-2zpw5   2/2     Running   0          10s

NAME                                                         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
service/galaxy-operator-controller-manager-metrics-service   ClusterIP   10.104.182.5   <none>        8443/TCP   10s

NAME                                                 READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/galaxy-operator-controller-manager   1/1     1            1           10s

NAME                                                           DESIRED   CURRENT   READY   AGE
replicaset.apps/galaxy-operator-controller-manager-d84cd6d4c   1         1         1       10s
```

## 4. Create Galaxy

The galaxy-operator code includes a sample galaxy-cr.yaml which can be deployed for basic local testing and to verify your built operator code:
```
kubectl create -f galaxy-operator/galaxy-cr.yaml
```
> (creates galaxy):
```
galaxy.galaxy.ansible.com/galaxy created
```
Check the pods:
```
kubectl get pods -n galaxy
```
> (wait for pods to all be running):
```
NAME                                                     READY   STATUS    RESTARTS   AGE
pod/galaxy-api-5d4d945787-jq2kk                          1/1     Running   0          2m12s
pod/galaxy-content-754466b885-8c85x                      1/1     Running   0          2m41s
pod/galaxy-content-754466b885-bgzz7                      1/1     Running   0          2m41s
pod/galaxy-operator-controller-manager-d84cd6d4c-2zpw5   2/2     Running   0          3m55s
pod/galaxy-postgres-13-0                                 1/1     Running   0          3m
pod/galaxy-redis-b77c7ccb-zqdv6                          1/1     Running   0          2m30s
pod/galaxy-web-dc44cff56-k46j2                           1/1     Running   0          2m53s
pod/galaxy-worker-64f7889dd7-t5jdd                       1/1     Running   0          2m36s
```
## 4. Access Galaxy User Interface
Obtain the galaxy admin password:
```
echo $(kubectl get -n galaxy secret galaxy-admin-password -o json | jq -r '.data.password' | base64 --decode)
```
Start minikube tunneling to make web interface available on ports 80 and 443:
```
minikube tunnel
```
> Note: You will be prompted for your password and the terminal must stay open for the tunnel to stay active.
```
✅  Tunnel successfully started

📌  NOTE: Please do not close this terminal as this process must stay alive for the tunnel to be accessible ...

❗  The service/ingress galaxy-ingress requires privileged ports to be exposed: [80 443]
🔑  sudo permission will be asked for it.
🏃  Starting tunnel for service galaxy-ingress.
Password:
```
You can now access Galaxy in your browser by visiting [http://localhost](http://localhost) or [https://localhost](https://localhost):
<img width="1326" alt="image" src="https://github.com/ansible/galaxy-operator/assets/87674982/5744a107-3630-4e8e-a674-3357da0cfa42">
<img width="1326" alt="image" src="https://github.com/ansible/galaxy-operator/assets/87674982/e4a66e4a-66ad-4995-a55f-414dd59f8fb7">