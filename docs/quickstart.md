# Galaxy-Operator Quickstart

Galaxy Operator and Galaxy-NG can be quickly deployed for local development and testing using any standard Kubernetes variant.

For local development and testing we recommend using the latest version of [podman-desktop](https://podman-desktop.io/) which contains all the necessary tools to build and deploy galaxy-operator and galaxy-ng.

In our example we will use [minikube](https://minikube.sigs.k8s.io/docs/) with [podman](https://podman.io/) as the driver.

## 1. Create Kubernetes Cluster

To get started stand up a local Kubernetes cluster by creating a minikube cluster with the ingress addon enabled:

```
minikube start --driver=podman --cpus=4 --memory=8g --addons=ingress
```
## 2. Create Galaxy Operator
Clone the latest galaxy-operator code:
```
git clone https://github.com/ansible/galaxy-operator
```
Apply the kustomization:
```
kubectl apply -k galaxy-operator
```
> (creates the operator and resouces):
```
# Warning: 'patchesStrategicMerge' is deprecated. Please use 'patches' instead. Run 'kustomize edit fix' to update your Kustomization automatically.
namespace/galaxy created
customresourcedefinition.apiextensions.k8s.io/galaxies.galaxy.ansible.com unchanged
customresourcedefinition.apiextensions.k8s.io/galaxybackups.galaxy.ansible.com unchanged
customresourcedefinition.apiextensions.k8s.io/galaxyrestores.galaxy.ansible.com unchanged
serviceaccount/galaxy-operator-sa created
role.rbac.authorization.k8s.io/galaxy-operator-galaxy-operator-role created
role.rbac.authorization.k8s.io/galaxy-operator-leader-election-role created
role.rbac.authorization.k8s.io/galaxy-operator-proxy-role created
clusterrole.rbac.authorization.k8s.io/galaxy-operator-galaxy-operator-cluster-role unchanged
clusterrole.rbac.authorization.k8s.io/galaxy-operator-metrics-reader unchanged
rolebinding.rbac.authorization.k8s.io/galaxy-operator-galaxy-operator-rolebinding created
rolebinding.rbac.authorization.k8s.io/galaxy-operator-leader-election-rolebinding created
rolebinding.rbac.authorization.k8s.io/galaxy-operator-proxy-rolebinding created
clusterrolebinding.rbac.authorization.k8s.io/galaxy-operator-galaxy-operator-cluster-rolebinding unchanged
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
NAME                                                      READY   STATUS    RESTARTS   AGE
pod/galaxy-operator-controller-manager-5f75d85bf8-bx88t   2/2     Running   0          12s

NAME                                                         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/galaxy-operator-controller-manager-metrics-service   ClusterIP   10.104.238.233   <none>        8443/TCP   12s

NAME                                                 READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/galaxy-operator-controller-manager   1/1     1            1           12s

NAME                                                            DESIRED   CURRENT   READY   AGE
replicaset.apps/galaxy-operator-controller-manager-5f75d85bf8   1         1         1       12s
```

## 2. Create Galaxy
The galaxy-operator code includes a sample galaxy-cr.yaml which can be deployed for basic local testing:
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
NAME                                                  READY   STATUS    RESTARTS   AGE
galaxy-api-5d4d945787-jtc59                           1/1     Running   0          2m54s
galaxy-content-754466b885-cmmp4                       1/1     Running   0          3m23s
galaxy-content-754466b885-zsfqq                       1/1     Running   0          3m23s
galaxy-operator-controller-manager-5f75d85bf8-j49mr   2/2     Running   0          4m21s
galaxy-postgres-13-0                                  1/1     Running   0          3m40s
galaxy-redis-994cbcbff-9rf55                          1/1     Running   0          3m11s
galaxy-web-dc44cff56-lmshc                            1/1     Running   0          3m33s
galaxy-worker-64f7889dd7-9lvkm                        1/1     Running   0          3m17s
galaxy-worker-64f7889dd7-kp6m7                        1/1     Running   0          3m17s
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