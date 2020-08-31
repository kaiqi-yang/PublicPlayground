# Section 13: Maintaining Sets of Containers with Deployments
0 / 17|1hr 32min

194. Updating Existing Objects
6min

195. Declarative Updates in Action
7min

```
❯ kubectl apply -f client-pod.yaml
pod/client-pod configured
```
- `kubectl describe <object type> <object name>`



196. Limitations in Config Updates
3min

- tried to update containerPort
  - Error went out and says that you can only change few properties
  - ![](Limitations%20in%20config%20updates.png)
  - ![](Limitations%20of%20Pods%20config.png)
197. Quick Note to Prevent an Error
1min

198. Running Containers with Deployments
6min

- `Deployments`
  - Another kind of `objects`
    - `Pods`
      - Runs one or more closely related containers
    - `Services`
      - Sets up networking in a Kubernetes Cluster
    - `Deployment`
      - Maintains a set of identical pods, ensuring that they have the correct config and that the right number exists. 

- Pods vs Deployments
  - `Pods`
    - Runs a single set of containers
    - Good for one-off dev purposes
    - Rarely used directly in production
  - `Deployments`
    - Runs a set of identical pods (one or more)
    - Monitors the state of each pod, updating as necessary
    - Good for dev
    - Good for production
    - Pod Template
      - ![](Pod%20Template.png)
  

199. Deployment Configuration Files
3min

200. Walking Through the Deployment Config
4min

201. Applying a Deployment
6min

202. Why Use Services?
5min

203. Scaling and Changing Deployments
7min

204. Updating Deployment Images
4min

205. Rebuilding the Client Image
3min

206. Triggering Deployment Updates
12min

207. Imperatively Updating a Deployment's Image
7min

208. Multiple Docker Installations
6min

209. Reconfiguring Docker CLI
6min

210. Why Mess with Docker in the Node?
5min