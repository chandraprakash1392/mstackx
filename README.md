## Take home test for DevOps/SysOps role – Level#3
### Setting up kubernetes cluster
```
1. Create an instance with Ubuntu 16.04 OS installed
2. Login to the machine through ssh or whatever protocol you want to use
3. Change user to root (this is needed to install different application and its dependencies)
4. run the command: bash k8s_cluster_creation.sh
```

### Setting up nginx ingress controller
`helm install --name nginx-ingress -f helm_charts/nginx-ingress-controller.yaml stable/nginx-ingress`

### Installing jenkins inside kubernetes cluster
`helm install --name jenkins -f helm_charts/jenkins.yaml stable/jenkins`
*This will also install the open source vulnerability scanner `Aqua Microscanner` plugin in jenkins to allow scanning the docker images built in pipeline*

### Installing media wiki
```
$ cd helm_charts/media_wiki
$ docker build -t *repository name* .
$ docker push *repository name*
$ cd helm-charts
$ *open the file values.yaml and update the dns name in line 25*
$ kubectl create ns *namespace*
$ helm install --name media_wiki --namespace *namespace*. -f values.yaml
```

### Installing private docker registry
```
1. Go into helm_charts directory
2. Open the docker-registry.yaml file
3. Go to line number 34 and update the dns name for your registry
4. Go to line number 67 & 68 and update the secret
```
Once these changes are saved, run the following command
`helm install --name docker-registry -f helm_charts/docker-registry.yaml stable/docker-registry`

### Installing istio
```
$ helm repo add istio.io https://storage.googleapis.com/istio-release/releases/1.1.7/charts/
$ helm repo list
$ helm install --name istio-init --namespace istio-system istio.io/istio-init
$ kubectl get crds | grep 'istio.io\|certmanager.k8s.io' | wc -l
$ helm install --name istio --namespace istio-system --set grafana.enabled=true istio.io/istio
$ kubectl get svc -n istio-system
$ kubectl get pods -n istio-system
```

### Installing kiali
```
Open the file helm_charts/kiali.yaml and update the dns entry in line number 38
```
Once done updating the file, run the following command:
`helm install --name kiali -f helm_charts/kiali.yaml istio.io/istio/charts/kiali`

### Installing dashboard with readonly access
`helm install --name dashboard --namespace kube-system -f helm_charts/dashboard.yaml stable/kubernetes-dashboard`
`kubectl apply -f helm_charts/dashboard-readonly-cr.yaml`
`token_name=$(kubectl get sa/dashboard-kubernetes-dashboard -n kube-system -oyaml | grep "dashboard-kubernetes-dashboard-token" | awk '{print $3}')`
`kubectl get secret $token_name -n kube-system -o jsonpath="{.data.token}" | base64 --decode`
*this will provide you the token to access dashboard in read-only mode*
