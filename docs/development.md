# Development Guide

There are development scripts and yaml examples in the [`dev/`](../dev) directory that, along with the ansible-up.sh and ansible-down.sh scripts in the root of the repo, can be used to build, deploy and test changes made to the gateway operator.


## Build and Deploy


If you clone the repo, and make sure you are logged in at the CLI with oc and your cluster, you can run:

```
export QUAY_USER=username
export NAMESPACE=galaxy
export TAG=test
./ansible-up.sh
```

You can add those variables to your .bashrc file so that you can just run `./ansible-up.sh` in the future.

> Note: the first time you run this, it will create quay.io repos on your fork. You will need to either make those public, or create a global pull secret on your Openshift cluster.

About 5 minutes after the script completes, you will have a fully functional Galaxy deployment. To get the URL:

```bash
oc get route
```

To get the admin password:

```bash
oc get secret admin-password-secret -o jsonpath={.data.password} | base64 --decode
```


## Clean up


Same thing for cleanup, just run ./ansible-down.sh and it will clean up your namespace on that cluster


```
./ansible-down.sh
```

