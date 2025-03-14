# K3D

## K3D vs K3S

| Feature                  | K3s                                                                                                                               | K3d                                                                                                      |
| ------------------------ | --------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| **Deployment Method**    | Runs Kubernetes clusters on <span style="color:red;">virtual machines</span> or physical hardware.                                | Runs Kubernetes (K3s) clusters inside <span style="color:red;">Docker </span>containers.                 |
| **Scalability**          | Requires manual configuration for multi-cluster setups.                                                                           | Easily supports multi-node and multi-cluster setups with Docker containers, offering higher scalability. |
| **Production Readiness** | Designed for <span style="color:red;">production-level workloads</span>, simulating standard Kubernetes environments effectively. | Primarily focused on local development, <span style="color:red;">CI/CD pipelines</span>, and testing.    |

## What is Argo CD?

Argo CD is a git-based continuous delivery tool designed specifically for Kubernetes. It automates the deployment of applications.

### How it works?

1. Monitors running applications and compares their state against the state in Git.
2. Automatically applies changes when updates are detected in the Git repository

## Our continuous integration(CI)
1. Configuration files are stored on GitHub
2. Argo CD monitors git repo for changes
3. When a change is detected Argo CD sync Kubernetes state to match with the one on GitHub
3. Our app is hosted on Docker Hub
4. When a new version of the app is pushed to Docker Hub, we have to update image tag in conf files on Github
5. Argo CD detects this change and updates Kubetnetes cluster 
6. Argo CD is stored in the 1st namespace
7. 2nd namespace is for the application that gonna be automatically deployed by Argo CD
### Deployment Workflow
1. Push an application to Docke Hub(`docker push docker.io/example-app:v2`)
2. Update Kubernetes deployment YAML in GitHub(`image docker.io/example-app:v2`)
3. Argo CD detects this change in GitHub and deploys the updated application to the Kubernetes cluster
