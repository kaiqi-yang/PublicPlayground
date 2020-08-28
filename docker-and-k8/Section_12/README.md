# Section 12: Onwards to Kubernetes!
0 / 17|1hr 46min

177. The Why's and What's of Kubernetes
8min

178. Kubernetes in Development and Production
6min

- ![](kubectl%20vs%20minikube.png)

179. Updated Minikube Install and Setup Info - macOS
1min

Updated Minikube Install and Setup Info - macOS
updated 8-4-2020

Install

In the upcoming lecture, Stephen will setup and install Minikube using Homebrew. The installation instructions have changed slightly.

Instead of running:

`brew cask install minikube`

We only need to run:

`brew install minikube`

Driver Options

Minikube now supports the use of many different drivers. Hyperkit is the current recommended default for macOS. If you do not have Docker Desktop installed, then you may need to install it using Homebrew:

`brew install hyperkit`

To start minikube with hyperkit:

`minikube start --driver=hyperkit`

To set Hyperkit as the default driver:

`minikube config set driver hyperkit`

Find the IP address of your cluster:

`minikube ip`

Docker Driver - Important

Currently, the docker driver is not supported for use in this course. It currently does not work with any type of ingress:

https://minikube.sigs.k8s.io/docs/drivers/docker/#known-issues

180. Minikube Setup on MacOS
6min

- MacOS install
  - brew
  - brew install kubectl
  - VirtualBox
  - brew install minikube
  - `minikube start`

181. Minikube Setup on Windows Pro
1min

182. Minikube Setup on Windows Home
1min

183. Minikube Setup on Linux
1min

184. Docker Desktop's Kubernetes instead of Minikube
1min
```
These instructions are for using Docker Desktop's built-in Kubernetes instead of minikube which is discussed in the lectures.

macOS
1. Click the Docker icon in the top macOS toolbar

2. Click Preferences

3. Click "Kubernetes" in the dialog box menu

4. Check the “Enable Kubernetes” box

5. Click "Apply"

6. Click Install to allow the cluster installation (This may take a while).

Usage
Going forward, any minikube commands run in the lecture videos can be ignored. Also, instead of the IP address used in the video lectures when using minikube, we use localhost.

For example, in the first project where we deploy our simple React app, using minikube we would visit:

192.168.99.101:31515

Instead, when using Docker Desktop's Kubernetes, we would visit: localhost:31515

Also, you can skim through the discussion about needing to use the local Docker node in the "Multiple Docker Installations" and "Why Mess with Docker in the Node" lectures, this only applies to minikube users.
```


185. Mapping Existing Knowledge
8min

- Commands for checking status
  - `minikube status`
  - `kubectl cluster-info`

- Docker compose vs Kubernetes
  - ![](Docker%20compose%20vs%20Kubernetes.png)
    - make sure our image is hosted on docker hub
    - Make one config file to create the container
    - make on config file to set up networking

186. Quick Note to Prevent an Error
1min
```
In the upcoming lecture, Stephen will be creating the client-pod.yaml configuration file. You may get a blank page with an error in your console when you attempt to run the pod or deployment in a future lecture:

react-dom.production.min.js:209 TypeError: this.state.seenIndexes.map is not a function

This is because we added the following line to our client/nginx/default.conf file in the earlier Docker lectures:

try_files $uri $uri/ /index.html;

This line was added to resolve some React Router issues our client app was having. However, it will break this demo because we have no Nginx container or Ingress service in place.

The best way to resolve this is to use Stephen's Client image in the pod and deployment for these demos, instead of your own:

image: stephengrider/multi-client
```

187. Adding Configuration Files
7min

188. Object Types and API Versions
7min
- ![](Object%20Types%20and%20API%20Versions.png)
- API Version
  - Each API version defines a different set of 'objects' we can use
  - ![](API%20version%20in%20a%20diagram.png)
  - Which API version to use is usually defined by the `object` you need.

189. Running Containers in Pods
9min
- `Node`
  - In the local env, it's the VM that created by `minicube`
  - It's been used to run one of more **objects**
- `Pod`
  - Which is one of many kinds of `objects`
  - Is a grouping of containers with a very common purpose
  - Pod is the smallest thing that kubernetes control, in other words, k8s is not responsible for creating containers
  - Pod should be a group of **tightly coupled containers**
  - ![](Potential%20usage%20of%20Pod.png)
- ![](Node%20Pod%20and%20container.png)

190. Service Config Files in Depth
14min

- `Services`
  - Another type of `objects`
  - Sets up networking in a K8S cluster
  - Services and subtypes 
    - ![](Services%20and%20subtypes.png)
- Local architecture in diagram
  - ![](Local%20architecture%20in%20diagram.png)
- subtype `NodePort`
  - Not preferred in prod env
    - because of the port mapping
  - Service NodePort and pod
    - ![](Service%20NodePort%20and%20pod.png)
    - The other specs for NodePort
      - `port`
        - Is for other pods that need multi-client pod
      - `targetPort`
        - the pod inside of the multi-client pod that we want to open the traffic to
      - `nodePort`
        -  the port exposed to the outside ie, browser
     -  port vs targetPort vs nodePort
        -  ![](port%20vs%20targetPort%20vs%20nodePort.png)

191. Connecting to Running Containers
10min

- Feed a config file to Kubectl
  - `kubectl apply -f <filename>`
    - ![](kubectl%20apply.png)
  - kubectl apply in action
    - kubectl apply in action
    ```
    client-node-port.yaml client-pod.yaml
    ❯ kubectl apply -f client-pod.yaml
    pod/client-pod created
    ❯ kubectl apply -f client-node-port.yaml
    service/client-node-port created
    ```
- Print the status of all running pods
  - `kubectl get pods`
    ```
    ❯ kubectl get pods
    NAME         READY   STATUS    RESTARTS   AGE
    client-pod   1/1     Running   0          2m14s
    ``` 
  - `kubectl get services`
    ```
    ❯ kubectl get services
    NAME               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
    client-node-port   NodePort    10.103.198.91   <none>        3050:31515/TCP   2m54s
    kubernetes         ClusterIP   10.96.0.1       <none>        443/TCP          23h
    ```
- To access it
  - `minikube service list`
    ```
    ❯ minikube service list
    |-------------|------------------|--------------|-----|
    |  NAMESPACE  |       NAME       | TARGET PORT  | URL |
    |-------------|------------------|--------------|-----|
    | default     | client-node-port |         3050 |     |
    | default     | kubernetes       | No node port |
    | kube-system | kube-dns         | No node port |
    |-------------|------------------|--------------|-----|
    ```
  - `minikube service client-node-port`
    ```

    ❯ minikube service client-node-port
    |-----------|------------------|-------------|-------------------------|
    | NAMESPACE |       NAME       | TARGET PORT |           URL           |
    |-----------|------------------|-------------|-------------------------|
    | default   | client-node-port |        3050 | http://172.17.0.3:31515 |
    |-----------|------------------|-------------|-------------------------|
    🏃  Starting tunnel for service client-node-port.
    |-----------|------------------|-------------|------------------------|
    | NAMESPACE |       NAME       | TARGET PORT |          URL           |
    |-----------|------------------|-------------|------------------------|
    | default   | client-node-port |             | http://127.0.0.1:55492 |
    |-----------|------------------|-------------|------------------------|
    🎉  Opening service default/client-node-port in default browser...
    ❗  Because you are using a Docker driver on darwin, the terminal needs to be open to run it.
    ```
  - the your app will be opened in browser

192. The Entire Deployment Flow
13min



193. Imperative vs Declarative Deployments
14min