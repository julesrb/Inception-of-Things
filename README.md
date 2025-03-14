# Inception of Things  - (in process...)
*A 42 System Administration Project*

## 📌 Overview  
Inception of Things is a project designed to introduce Kubernetes through **K3s**, **K3d**, and **Vagrant**. The goal is to gain hands-on experience in setting up **virtualized environments**, deploying applications in Kubernetes, and implementing **GitOps** workflows with **Argo CD**.

---

## 📂 Project Breakdown  

### **1️⃣ Part 1: K3s and Vagrant**  
In this part, the objective is to set up a **lightweight Kubernetes cluster** using **K3s** inside a virtualized environment managed by **Vagrant**. This includes configuring **a master node and a worker node**, setting up **networking**, and ensuring seamless communication between the machines.

```mermaid
graph TD;
    A[Host Machine] -->|Runs| B[Vagrant]
    B -->|Creates VM| C[VM 1 - Master Node]
    B -->|Creates VM| D[VM 2 - Worker Node]
    C -->|Runs| E[K3s Instance Server]
    D -->|Runs| F[K3s Instance Agent]



### **2️⃣ Part 2: Deploying Applications on K3s**  
With a Kubernetes cluster running, the next step is to deploy three **web applications** with different scaling needs. This includes **configuring services, ingress rules**, and ensuring the correct distribution of requests among replicas.

### **3️⃣ Part 3: K3d and Argo CD**  
This part replaces Vagrant with **K3d**, a lightweight Kubernetes distribution running in Docker. Additionally, **Argo CD** is introduced to manage **continuous deployment**, allowing applications to be deployed automatically through a Git-based workflow.

### **🌟 Bonus: GitLab CI/CD**  
The final (optional) part involves **hosting GitLab within the Kubernetes cluster** and integrating it with a **CI/CD pipeline**, automating the entire deployment process from code changes to production.


