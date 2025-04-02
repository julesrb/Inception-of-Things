# Inception of Things

Inception of Things is a DevOps practice project focused on implementing modern infrastructure and deployment workflows. The goal is to gain hands-on experience with virtualization tools, Kubernetes orchestration, and GitOps methodologies. The project progresses through increasingly complex setups, culminating in a fully automated CI/CD pipeline.

---

### **Part 1: K3s and Vagrant**  
This section establishes the foundation by creating a lightweight Kubernetes cluster using K3s inside Vagrant-managed virtual machines. The setup includes:

- Provisioning a master node and worker node via Vagrant  
- Configuring K3s in server (control plane) and agent (worker) modes  
- Setting up proper networking between virtual machines  
- Validating cluster communication and basic functionality  

### **Part 2: Deploying Applications on K3s**  
With the cluster operational, this phase focuses on deploying and managing applications:

- Deployment of three web applications with different scaling requirements  
- Configuration of Kubernetes Services for internal networking  
- Implementation of Ingress rules for external access  
- Load testing and scaling validation  

### **Part 3: K3d and Argo CD**  
The project evolves by replacing the Vagrant environment with containerized infrastructure:

- Migration to K3d (K3s in Docker) for lightweight cluster management  
- Installation and configuration of Argo CD for GitOps workflows  
- Implementation of declarative application deployments via Git repositories  
- Synchronization and drift detection mechanisms  

### **Bonus: Self-Hosted GitLab CI/CD with Argo CD Integration**  
The most advanced section focuses on creating a complete, self-contained CI/CD ecosystem:

#### **Offline GitLab Installation:**
- Deployment of GitLab using Helm charts on the K3d cluster  
- Configuration of persistent storage for repositories and artifacts  
- Setup of internal container registry for image management  

#### **CI Pipeline Construction:**
- Creation of project-specific `.gitlab-ci.yml` files  
- Implementation of automated build, test, and packaging stages  
- Integration with the GitLab Container Registry  

#### **Argo CD GitOps Workflow:**
- Automatic synchronization between GitLab repositories and cluster state  
- Deployment approval workflows and health monitoring  
- Rollback mechanisms through Git history  

#### **Full Automation:**
- Webhook triggers from GitLab to Argo CD  
- End-to-end testing of the push-to-deploy pipeline  
- Security considerations for self-hosted environments  

This bonus section provides a comprehensive on-premises solution for development teams needing an air-gapped or private CI/CD system, combining GitLab's powerful automation features with Argo CD's GitOps capabilities in a lightweight Kubernetes environment.

