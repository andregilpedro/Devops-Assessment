# Configure and deploy the k8s cluster using Kops

In this section we will go over the k8s necessary configurations.

### Create a service account with access to one namespace only

In order to achieve this we will create the account bob that will only have access to the namespace bobspace:
* Create the bobspace namespace `kubectl create namespace bobspace`
* Create a service account called bob, a role that allows full access on this namespace and bind it to bob using [this configuration](./serviceAccount.yaml) to apply it: `cd ~/Devops-Assessment/kubernetes && kubectl create -f serviceAccount.yaml`

### Deploy our services

* Create secrets for mongodb user and password variables:
```bash
kubectl create secret generic creds \
  --from-literal="MONGODB_USER=devops" \
  --from-literal="MONGODB_PASSWORD=wPxp9hOqyw3wrTFy"
```
* I've created 2 yaml config files, each containing a deployment and a service for the [api](./api.yaml) and [app](./app.yaml), apply these configurations `kubectl apply -f api.yaml && kubectl apply -f app.yaml`
* To not expose the app to the public internet change the value `loadBalancerSourceRanges: 0.0.0.0/0` in the [app](./app.yaml) file to your own public IP (or any other of your choice)
* Run `kubectl get svc/frontend` to get the exposed endpoint and access it
* The Dockerfiles used are on this folder [here](./docker)

### Install Metrics Server

To get some metrics of our kubernetes cluster we can deploy the Metrics Server:
`kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml`
We can then run `kubectl top nodes` or `kubectl top pods` to check if it's working.

### kubernetes-dashboard

kubernetes-dashboard is a general purpose, web-based UI for Kubernetes clusters. It allows users to manage applications running in the cluster and troubleshoot them, as well as manage the cluster itself.

Since we're behind a private cloud and using a "middle man" EC2 instance it was a hard task to make this solution work so I just dropped the EC2 instance and did the same process but using my computer instead to be able launch `kubectl proxy` and view the dashboard locally.

#### Install and use kubernetes-dashboard

* Deploy it using `kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.3.1/aio/deploy/recommended.yaml`
* Run `kubectl proxy` to allow you to access the cluster services i.e. access kubernetes-dashboard throught http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
* In order to access we need a token from a user on the namespace kubernetes-dashboard, you can just run `kubectl apply -f dashboard-user.yaml` to create a admin user and then `kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"` to get the token