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

190. Service Config Files in Depth
14min

191. Connecting to Running Containers
10min

192. The Entire Deployment Flow
13min

193. Imperative vs Declarative Deployments
14min