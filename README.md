# 🛒 Capstone: Cloud-Native E-Commerce Deployment on AWS

### **Infrastructure Repository – Team 4, Seneca Polytechnic (Cloud Architecture & Administration)**

This repository contains the **entire Infrastructure-as-Code (IaC)** used to deploy the **ProShop v2 MERN e-commerce application** onto AWS using a fully automated, production-style cloud architecture.

The deployment is built with:

- **Terraform** (modular, reusable IaC)
- **Amazon EKS** (Kubernetes cluster)
- **Amazon ECR** (Docker image registry)
- **GitHub Actions OIDC** (secure CI/CD pipelines)
- **AWS Secrets Manager** (secure and encrypted secret storage)
- **Kubernetes Horizontal Pod Autoscaling (HPA)**
- **AWS Load Balancer Controller + Ingress**
- **Amazon CloudWatch Dashboards & Logs**

This project focuses **only on infrastructure and DevOps**, not on writing or modifying the MERN application itself.  
Everything is written in a simple, beginner-friendly style while following real industry best practices.

---

## 📦 What This Project Is About

This capstone demonstrates how to deploy a real, production-style e-commerce platform using:

- Containers
- Kubernetes
- AWS cloud services
- Modern DevOps automation

The project reflects how a real company runs and scales applications using microservices, CI/CD pipelines, and secure secret management.

---

### 🧩 **Application Components**

- **Frontend:** React (served via Nginx container)
- **Backend:** Node.js + Express
- **Database:** MongoDB Atlas (managed, external database)
- **Payments:** PayPal Sandbox API

---

## 🛠️ What This Repository Does

This infrastructure repository is responsible for:

### ✔️ **1. Creating all cloud resources**

For both **development** and **production**, including:

- VPCs
- Subnets
- Route tables
- Security groups
- NAT gateway
- ECR Repositories
- EKS cluster
- Node groups
- IAM Roles + OIDC
- ... and many more

### ✔️ **2. Deploying the Application to EKS**

Terraform provisions the cluster and then automatically deploys:

- Frontend deployment
- Backend deployment
- Kubernetes services
- Ingress routing

### ✔️ **3. Automating CI/CD**

Using GitHub Actions OIDC:

- Build Docker images
- Push to Amazon ECR

### ✔️ **4. Managing Secrets Securely**

- AWS Secrets Manager stores sensitive configuration
- IRSA allows pods to read secrets with **no static credentials**

### ✔️ **5. Enabling Auto-Scaling**

- Horizontal Pod Autoscaler manages frontend + backend replicas
- Metrics Server provides CPU metrics

### ✔️ **6. Routing Traffic with ALB**

- AWS Load Balancer Controller creates ALB
- Ingress rules route traffic to frontend + backend pods

### ✔️ **7. Setting Up Monitoring**

- CloudWatch logs for pods
- CloudWatch dashboards for cluster + application visibility

### 🚀 Final Outcome

This repository delivers a **complete, end-to-end, cloud-native deployment pipeline** for a MERN e-commerce application:

- Fully automated provisioning
- Secure and scalable Kubernetes cluster
- Continuous deployment using GitHub Actions
- Production-ready infrastructure
- Clear separation between **dev** and **prod**
- Real-world cloud engineering and DevOps workflows

All powered by Terraform and AWS.

---

## 🧮 Budget Estimate – Development Environment

| **Component**                               | **Quantity / Configuration** | **Unit Price (USD)** | **Estimated Monthly Cost** |
| ------------------------------------------- | ---------------------------- | -------------------- | -------------------------- |
| **EKS Control Plane Fee**                   | 1 cluster × 720 hrs          | $0.10/hr             | $72.00                     |
| **Worker Nodes (EC2 t3.small)**             | 2 nodes × 720 hrs            | $0.0208/hr           | $29.95                     |
| **NAT Gateway & Data Transfer (approx)**    | 1 NAT + modest traffic       | Estimate ~ $30       | ~$30.00                    |
| **ECR & Storage & Other Services (approx)** | Basic usage                  | Estimate ~ $10       | ~$10.00                    |
| **Estimated Monthly Total (Dev)**           | —                            | —                    | **~ $141.95 (~$140)**      |

**Note:** Dev uses smaller nodes and lower replicas. Additional charges may include:  
Load balancer hourly fees, EBS volume storage, inter-AZ data transfer, CloudWatch logs, etc.

---

## 📊 Budget Estimate – Production Environment

| **Component**                                     | **Quantity / Configuration**   | **Unit Price (USD)** | **Estimated Monthly Cost** |
| ------------------------------------------------- | ------------------------------ | -------------------- | -------------------------- |
| **EKS Control Plane Fee**                         | 1 cluster × 720 hrs            | $0.10/hr             | $72.00                     |
| **Worker Nodes (EC2 t3.small or larger)**         | 3 nodes × 720 hrs              | $0.0208/hr ×3        | $44.93                     |
| **Load Balancer + Ingress + Public ALB**          | 1 ALB (hourly + data transfer) | Estimate ~ $30       | ~$30.00                    |
| **NAT Gateway & Private Subnets (higher usage)**  | 1 NAT + more outbound traffic  | Estimate ~ $40       | ~$40.00                    |
| **ECR & Storage & Image Scanning (high traffic)** | Higher usage than dev          | Estimate ~ $20       | ~$20.00                    |
| **Monitoring & CloudWatch Dashboards**            | Increased logs + metrics usage | Estimate ~ $15       | ~$15.00                    |
| **Estimated Monthly Total (Prod)**                | —                              | —                    | **~ $221.93 (~$220–$230)** |

**Note:** Prod uses more nodes, higher traffic, and full HA configuration. Additional cost may include:  
Multi-AZ NAT, extra load balancers, higher log retention, EBS volumes, increased data transfer, etc.

---

### 📌 Key Assumptions & Notes

- **Region:** US East (N. Virginia) pricing.
- **Worker node type:** t3.small (2 vCPU, 2 GiB RAM). Larger node types (t3.medium, m5.large, etc.) increase cost.
- **EKS control plane:** $0.10/hr for standard support. Older Kubernetes versions in extended support cost **$0.60/hr**.
- **NAT Gateway cost:** Highly dependent on outbound traffic. Provided value is an estimate.
- **Load Balancer cost:** Influenced by hourly usage and data processing.
- **ECR costs:** Vary based on storage size, scan frequency, and repository traffic.
- Estimates **do not include**:
  - MongoDB Atlas
  - Route 53 / domain registration
  - Reserved Instances / Savings Plans
  - Third-party services

---

### 🔍 Summary

- **Dev Environment (~$140/month)**  
  Suitable for testing, CI/CD experimentation, and low-traffic demos.

- **Prod Environment (~$220–$230/month)**  
  Appropriate for a production-style architecture with high availability, autoscaling, monitoring, and greater traffic expectations.

**Note:** Actual AWS costs may vary based on region, traffic patterns, data transfer usage, instance types, and log retention settings. These estimates represent a baseline for typical low-to-moderate usage and should be validated using the AWS Pricing Calculator for your specific workload.

---

## 🔄 Cost-Optimized Production Alternatives

To make this architecture more affordable while still keeping it production-ready, here are the best long-term optimization strategies:

---

### **1. Replace NAT Gateway with VPC Endpoints**

NAT Gateway is one of the most expensive components in the architecture.  
You can dramatically reduce cost by removing the NAT and using **VPC Interface Endpoints** for:

- ECR (API + DKR)
- S3 Gateway Endpoint
- CloudWatch Logs
- CloudWatch Metrics
- Secrets Manager
- STS

**Result:**  
Private subnets retain AWS access without paying $30–$50/month for NAT.

---

### **2. Right-Size & Mix Worker Nodes**

Choose smaller worker node types or mix instance classes:

- Use `t3.small` or `t3.medium` where possible
- Introduce **Spot Instances** for frontend workloads
- Keep only backend-critical workloads on On-Demand nodes

**Result:**  
Compute cost drops significantly while keeping performance.

---

### **3. Use One ALB with Routing Rules**

Avoid multiple load balancers unless absolutely required.  
A single ALB can easily route:

- `/*` → frontend
- `/api/*` → backend

**Result:**  
Saves ~$20–$30 per month and simplifies the architecture.

---

### **4. Reduce Log Retention**

CloudWatch charges can spike over time.

Recommended retention:

- **Dev:** 7–14 days
- **Prod:** 30 days

**Result:**  
Lower storage cost and easier log management.

---

### **5. Prune ECR Images**

Old images accumulate quickly.  
Use lifecycle rules to keep only:

- Latest 10 tagged images
- Delete untagged images after 7 days

**Result:**  
Lower ECR storage cost and cleaner registry.

---

## 💰 Cost Reduction Estimate

If the above optimizations are applied:

- **Total cost reduction:** ~45–60%
- **Major savings from:**
  - Removing NAT Gateway
  - Downsizing worker nodes
  - Adding Spot instances
  - Reducing unnecessary storage (ECR + logs)

This produces a **much more cost-efficient**, clean, and still **production-grade** Kubernetes environment.

---

## 📁 Repository Structure\*\*

```
CAPSTONE-INFRA-TEAM4/
│
├── .github/workflows/
│   └── terraform.yml                 # CI: fmt, validate, plan on `PRs` and `merges` in main branch
│
├── infra/
│   └── envs/
│       ├── dev/                      # Development environment
│       │   ├── main.tf
│       │   ├── dev.tfvars
│       │   ├── outputs.tf
│       │   ├── variables.tf
│       │   └── versions.tf
│       │
│       └── prod/                     # Production environment
│           ├── main.tf
│           ├── prod.tfvars
│           ├── outputs.tf
│           ├── variables.tf
│           └── versions.tf
│
├── modules/
│   ├── vpc/
│   ├── ecr/
│   ├── eks/
│   └── secrets/
|   |── cloudwatch/
│
└── README.md

```

---

## 🧰 Tools You Must Install (Local Setup) – Download Links

Here are the current official installation links for each required tool.

| Tool                  | Download Link                                                                                                |
| --------------------- | ------------------------------------------------------------------------------------------------------------ |
| **Git**               | [Get Git](https://git-scm.com/install/) :contentReference[oaicite:0]{index=0}                                |
| **AWS CLI**           | [AWS CLI](https://aws.amazon.com/cli/) :contentReference[oaicite:1]{index=1}                                 |
| **Terraform (v1.9+)** | [Install Terraform](https://developer.hashicorp.com/terraform/install) :contentReference[oaicite:2]{index=2} |
| **kubectl**           | [Install kubectl](https://kubernetes.io/releases/download/) :contentReference[oaicite:3]{index=3}            |
| **Helm**              | [Helm releases / install](https://github.com/helm/helm/releases) :contentReference[oaicite:4]{index=4}       |
| **Docker (Desktop)**  | [Docker Desktop](https://www.docker.com/products/docker-desktop/) :contentReference[oaicite:5]{index=5}      |
| **Node.js + npm**     | [Download Node.js](https://nodejs.org/en/download/) :contentReference[oaicite:6]{index=6}                    |

---

## 🧩 Prerequisites Before Deployment

Before running Terraform for either **dev** or **prod**, a few resources must be created manually in AWS.  
These cannot be provisioned through Terraform because they are required _before_ Terraform initializes or retrieves state.

---

### ### 🔐 1. AWS Secrets Manager — Required for Both Environments

Create the following secrets **manually** in AWS Secrets Manager:

#### **Development Environment Secrets**

- `/proshop/dev/MONGO_URI`
- `/proshop/dev/JWT_SECRET`
- `/proshop/dev/PAYPAL_CLIENT_ID`
- Any additional environment-specific app secrets can be found in Capstone-WebApp README.

#### **Production Environment Secrets**

- `/proshop/prod/MONGO_URI`
- `/proshop/prod/JWT_SECRET`
- `/proshop/prod/PAYPAL_CLIENT_ID`
- Any additional production-specific secrets

These values are pulled by EKS pods at deployment time using IRSA authentication.

---

### 📦 2. S3 Buckets for Terraform Remote State

Create **two separate S3 buckets** manually — one for each environment:

- `capstone-team4-dev-state`
- `capstone-team4-prod-state`

These store remote Terraform state files to prevent local corruption and ensure team collaboration.

_Buckets must have_:

- Versioning **enabled**
- Block Public Access **enabled**

Terraform will reference these buckets in each environment's backend configuration.

---

### 🗄 3. DynamoDB Tables for State Locking

Create **two** DynamoDB tables manually to enable Terraform state locking:

- `capstone-team4-dev-lock`
- `capstone-team4-prod-lock`

Each table must have a primary key:

- **Partition Key:** `LockID` (String)

Terraform uses these tables to prevent simultaneous writes to state, which protects against state corruption.

---

**Note:**

- Choose the correct installer for your operating system (Windows, macOS, Linux) and architecture (x64, ARM64) when available.
- For tools with multiple versions (e.g., Terraform, Node.js), it is generally safe to install the ➤ latest stable or LTS version unless your project explicitly requires an older version.
- After installation, verify each tool by running its version command (e.g., `git --version`, `terraform -v`, `kubectl version`) to ensure the installation succeeded.

---

## 🧩 Environment Separation — Dev vs Prod

Both environments use the same module, but configuration differs using `.tfvars` files.

### **Development Environment**

- Lower replica count.
- Smaller instance types.
- Used for testing and validation.

### **Production Environment**

- Higher replica count and larger nodes.
- Designed for high availability and reliability.

Environment-specific configuration files:

- `dev.tfvars`
- `prod.tfvars`

---

## 🏗 Architecture Overview

**Below is the high-level architecture (explained simply):**

## 🏗️ VPC Module

The **VPC module** forms the core networking foundation of the project. It provisions a secure, isolated, and highly available network environment where all AWS resources such as EKS, ALB, and supporting services operate.

### 📘 Overview

This module creates a **custom Virtual Private Cloud (VPC)** with both **public** and **private** subnets distributed across two Availability Zones for redundancy and high availability. It configures all essential networking components—VPC, subnets, route tables, gateways, and security groups—to ensure reliable communication and strict traffic isolation.

### 🔧 Key Components

- **VPC** – Custom CIDR block defined per environment (`dev` and `prod`) with DNS hostnames and DNS resolution enabled.
- **Subnets** – Six total subnets (three tiers across two AZs):
  - Public subnets for the ALB and NAT Gateway
  - Private frontend subnets for EKS worker nodes
  - Private backend subnets for internal application components
- **Internet Gateway (IGW)** – Provides inbound and outbound connectivity for public subnets.
- **NAT Gateway** – Deployed in a public subnet to allow private subnets secure outbound internet access without exposing them publicly.
- **Route Tables** –
  - Public route table routes `0.0.0.0/0` to the Internet Gateway.
  - Private route table routes `0.0.0.0/0` through the NAT Gateway.
- **Security Groups** –
  - **ALB SG:** Allows inbound HTTP (port 80) from the internet and outbound to EKS nodes.
  - **Node SG:** Allows inbound traffic only from the ALB SG and outbound HTTPS (port 443) for external dependencies.

### 🌐 Environment Separation

Both environments use this same module with **non-overlapping CIDR ranges** for complete isolation:

- **Development VPC:** `10.0.0.0/16`
- **Production VPC:** `10.1.0.0/16`

Each environment maintains its own Terraform state for independent deployment and management.

### 🧱 Networking Summary

- Two Availability Zones ensure high availability.
- Clear separation between public and private layers.
- NAT Gateway secures outbound access from private nodes.
- Backend workloads remain isolated from direct public exposure.
- Dynamic tagging applied for environment, project, and ownership tracking.

### ✅ Outcome

The VPC module delivers a **scalable, secure, and production-ready network architecture** that forms the foundation for all subsequent AWS components in this project.

---

## 🐳 ECR Module (Elastic Container Registry)

The ECR module is responsible for creating and managing all Docker image repositories used in this project.  
It is written in Terraform and designed to work for both **development** and **production** environments with the same reusable structure.

---

### 📘 Overview

This module automates the setup of Amazon ECR (Elastic Container Registry) where Docker images are securely stored and scanned.  
It ensures that all repositories follow best practices for security, maintenance, and consistency across environments.  
Each environment (dev and prod) calls this same module with environment-specific values.

---

### ⚙️ What the Module Does

- **Creates multiple repositories** for each application service (frontend, backend, and nginx).
- **Enables image scanning** on every image push to identify vulnerabilities automatically.
- **Applies encryption at rest** using AES256 to protect container images stored in ECR.
- **Implements a lifecycle policy** that deletes untagged images after 7 days and keeps only the latest tagged versions.
- **Supports environment tagging** so each repository clearly indicates whether it belongs to dev or prod.
- **Provides Terraform outputs** that expose repository names and URIs for integration with the CI/CD pipeline.

---

### 🔐 Security and Compliance

All images pushed to ECR are automatically encrypted and scanned.  
This ensures compliance with secure container management practices.  
The module also allows tag mutability control — mutable tags are used in development for quick testing, while immutable tags can be used in production to prevent overwriting stable images.

---

### 🧩 Environment Separation

Development and production environments use separate repositories to avoid conflicts and allow independent testing and deployment.  
Each repository follows a consistent naming convention and includes environment labels for clear visibility in the AWS Console.

---

### 🔄 Lifecycle Management

A cleanup policy keeps the storage efficient and organized:

- Untagged images older than 7 days are automatically removed.
- Only the 10 most recent tagged images are retained.  
  This prevents unnecessary cost and maintains repository hygiene.

---

### 🚀 CI/CD Integration

The CI/CD pipeline in the **Capstone-WebApp** repository builds Docker images for all services and pushes them to ECR.  
The workflow automatically checks which repositories (dev or prod) exist and pushes the images to the appropriate ones.  
Each image is tagged with both the commit SHA for version tracking and the “latest” tag for convenience.  
Authentication to AWS is handled through **GitHub OIDC**, eliminating the need for long-lived AWS access keys.

---

### 🧱 Infrastructure Design Highlights

- Built entirely using Terraform for automation and repeatability.
- Uses secure defaults like AES256 encryption and vulnerability scanning.
- Provides clean separation between environments while maintaining naming consistency.
- Lifecycle rules ensure old images are cleaned automatically.
- Simplifies integration with downstream services such as EKS or ECS for deployment.

---

### ✅ Summary

The ECR module provides a secure and scalable image management foundation for the entire project.  
It combines best practices in security, automation, and lifecycle management, ensuring both development and production environments have reliable, clean, and traceable image repositories.  
This setup supports an efficient CI/CD process where every image build is automatically stored, scanned, and versioned in AWS ECR.

---

## ☸️ Amazon EKS Module — Kubernetes Cluster Orchestration

The **Amazon Elastic Kubernetes Service (EKS) module** provisions and manages a fully automated Kubernetes cluster on AWS using Terraform.  
It handles cluster creation, networking, IAM integration, scaling, application deployment, and load balancing.  
This module acts as the **core orchestration layer** for running all containerized components of the project.

---

### 🔍 Purpose of the Module

The module automates the deployment of a **production-grade Kubernetes environment**.  
It ensures consistent, secure, and scalable infrastructure for both **development** and **production**, eliminating manual configuration effort.

---

### ⚙️ Key Components

### 1. **EKS Cluster and Node Groups**

- Provisions a fully managed EKS control plane.
- Launches worker nodes through managed node groups.
- Configures autoscaling with min/max/desired node counts.
- Deploys nodes into **private subnets** to enhance security.

### 2. **IAM and OIDC Integration**

- Creates IAM roles for the cluster and node groups.
- Enables an OIDC provider for authentication between AWS and Kubernetes.
- Implements **IRSA (IAM Roles for Service Accounts)** so pods can securely access AWS services (e.g., Secrets Manager) without hard-coded credentials.

### 3. **Helm-Based Add-ons**

Installs essential Kubernetes components using Helm:

- **AWS Load Balancer Controller** – manages creation of AWS ALBs for ingress.
- **Metrics Server** – enables resource-based autoscaling.

List all Helm releases in the cluster:

```
helm list -A
```

### 4. **Application Deployments**

- Deploys both **frontend** (React/Nginx) and **backend** (Node/Express) applications from ECR.
- Uses Kubernetes Services for internal communication.
- Configures an Ingress resource for ALB routing:
  - `/api/*` → backend service
  - `/*` → frontend service

### 5. **Horizontal Pod Autoscaling (HPA)**

- Scales pods automatically based on CPU utilization.
- Ensures stable performance and cost-efficient workloads.

---

## 🧩 Useful EKS Verification Commands

Run these after updating kubeconfig.

### 🔹 1. Connect to the Cluster

`aws eks update-kubeconfig --region us-east-1 --name <cluster_name>`

### **2. Check Cluster Nodes**

`kubectl get nodes -o wide`

### **3. Verify Pods**

`kubectl get pods -n proshop`

### **4. Check Deployments**

`kubectl get deployments -n proshop`

### **5. Inspect Horizontal Pod Autoscalers (HPA)**

`kubectl get hpa -n proshop`

### **6. List Services**

`kubectl get svc -n proshop`

### **7. View Ingress and ALB URL**

`kubectl get ingress -n proshop`

### **8. Check Backend Logs**

`kubectl logs -n proshop -l app=backend --tail=50`

### **9. Check Frontend Logs**

`kubectl logs -n proshop -l app=frontend --tail=50`

### **10. Describe a Pod (Detailed Debug)**

`kubectl describe pod <pod_name> -n proshop`

### **11. Refresh or Recreate Ingress**

`kubectl delete ingress proshop-ingress -n proshop`  
`kubectl apply -f ingress.yaml`

### **12. Check Load Balancer Controller Logs**

`kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller`

---

### 🔐 Secrets and Configuration Management

- Integrates with **AWS Secrets Manager** to store sensitive configuration.
- Terraform retrieves secrets and injects them as environment variables into Kubernetes.
- Prevents storing any sensitive data inside Git repositories.

### ✅ Final Outcome

After applying the EKS module:

- A fully functional EKS cluster is deployed.
- Applications are automatically deployed, load balanced, and autoscaled.
- Infrastructure becomes **reproducible**, **secure**, and **fully automated** using Terraform.

---

## ⚙️ Terraform – How to Deploy

**IMPORTANT:**  
Before deploying, create your own `prod.tfvars` file and fill in all required variable values.

The EKS module must be deployed **only after** the ECR repositories contain images.  
Follow the sequence below carefully to avoid deployment errors.

---

### ✅ Step 1 — Clone the Repository

`git clone https://github.com/<your-org>/CAPSTONE-INFRA-TEAM4.git`  
`cd infra/envs/prod`

---

### ✅ Step 2 — Comment Out the EKS Module

In the `main.tf` for the **prod/dev environment**, temporarily comment out the entire EKS module block.

You should only deploy:

- VPC
- ECR

This ensures the EKS cluster does not attempt to pull images before they exist.

---

### ✅ Step 3 — Initialize Terraform

`terraform init`

---

### ✅ Step 4 — Deploy Only VPC + ECR

`terraform apply -var-file="prod.tfvars"`

Terraform will create:

- VPC
- Subnets
- Route tables
- Security groups
- ECR repositories

**Do NOT deploy EKS yet.**

---

## 🐳 Push Docker Images to ECR (Required Before EKS Deployment)

After the ECR repositories are created, you must push the latest frontend and backend images.

### ✔ Option A — Use the Team Repository (Capstone-WebApp) --> only for members who are contributors

1. Go to **GitHub → Capstone-WebApp**
2. Open the **Actions** tab
3. Run the **latest CI/CD pipeline**
4. Wait for it to:
   - Build Docker images
   - Tag them correctly
   - Push them to your new ECR repositories

---

### ✔ Option B — Use Your Own GitHub Account

If you want the pipelines under your own GitHub account:

1. Fork or clone the **Capstone-WebApp** repo
2. Add your GitHub Secrets for CI/CD:
   - `AWS_ROLE_TO_ASSUME`
   - `AWS_REGION`
   - `ECR_REPO_PREFIX`
   - Any other required variables
3. Trigger the workflow from **your own Actions tab**
4. Wait for the images to be pushed into your ECR repositories

---

### ⚠️ Important Warning

If you deploy EKS **before** ECR has images, Kubernetes will fail to start pods because:

- The images do not exist
- The deployments reference non-existent tags
- The cluster cannot pull anything from ECR

This will cause ImagePullBackOff errors.

---

## 🚀 Step 5 — Deploy the EKS Cluster

Once images are confirmed in ECR:

1. **Uncomment the EKS module** in `main.tf`
2. Re-run Terraform with the same variables:

`terraform apply -var-file="prod.tfvars"`

Terraform will now:

- Create the EKS cluster
- Provision node groups
- Deploy the backend and frontend
- Create Ingress + ALB
- Attach IAM Roles via IRSA
- Load secrets from Secrets Manager
- Configure Horizontal Pod Autoscaling

---

Following these steps ensures the environment deploys cleanly without image-related errors.

---

## 🌐 7. Accessing the Application

### **Get the ALB DNS Name**

`kubectl get ingress -n proshop`

Open the **ADDRESS** value (ALB hostname) in any web browser to access the application using **http://<alb_url>**.

---

## 🔐 Security Best Practices Used

This deployment follows multiple production-grade security practices:

- Fully private EKS worker nodes
- Only the ALB is publicly reachable
- IRSA (IAM Roles for Service Accounts) for secure pod identity
- No AWS access keys stored in pods or images
- Sensitive data stored securely in Secrets Manager
- Terraform state stored remotely in S3 with DynamoDB locking
- Immutable ECR tags in production
- Kubernetes namespaces used for logical isolation
- Autoscaling protects application performance under load

---

## 🧹 9. Cleanup

Terraform destroy can occasionally fail with **context deadline exceeded**, especially when Kubernetes resources (like Ingress) have stuck finalizers.  
Use the following cleanup procedure to safely and fully destroy the infrastructure.

---

### **Step 1 — Identify any blocking finalizers**

Finalizers may prevent Terraform from deleting Kubernetes resources.  
Check the Ingress resource:

`kubectl get ingress proshop-ingress -n proshop -o yaml`

---

### **Step 2 — Remove stuck finalizers (Recommended)**

If the Ingress contains a `finalizers:` section, remove it.
Run the below command in **Bash** terminal:

`kubectl patch ingress proshop-ingress -n proshop -p '{"metadata":{"finalizers":[]}}' --type=merge`

To ensure Terraform does not continue tracking the stuck namespace resource:

`terraform state rm module.eks.kubernetes_namespace.proshop`

---

### **Step 3 — Verify deletion**

Confirm that the Ingress has been successfully removed:

`kubectl get ingress -n proshop`

---

### **Step 4 — Run Terraform destroy again**

Re-run the destroy command:

`terraform destroy -var-file="prod.tfvars"`

Terraform will then successfully delete:

- VPC
- Subnets
- NAT Gateway
- EKS Cluster
- ALB
- All Kubernetes workloads and associated resources

**Note:** Images under ECR are not automatically deleted and must be removed manually.

---

### **Step 5 — If the state is locked, force unlock it**

If Terraform gets stuck due to a lock:

`terraform force-unlock <LOCK_ID>`

This ensures the state can continue with deletion or re-runs without interruption.

---

## 🚀 Future Enhancements

Optional improvements that can be added later:

- Route 53 domain integration + HTTPS certificates
- Prometheus + Grafana monitoring stack
- Karpenter or Cluster Autoscaler for smarter scaling
- Multi-node-group architecture (compute-optimized, memory-optimized, etc.)
- Blue/Green or Canary deployment strategies
- Argo CD for full GitOps automation

---

## 🏁 11. Summary

This project demonstrates a complete, production-style deployment of a cloud-native e-commerce application using AWS and modern DevOps tooling.

By the end of this setup, you have:

- Secure private VPC networking
- Automated container image builds
- Reliable and secure ECR storage
- A production-ready EKS cluster with autoscaling
- Traffic routed through an ALB ingress
- Secrets stored securely in AWS Secrets Manager
- CI/CD pipelines powered by GitHub Actions OIDC
- Separation of **development** and **production** environments

This is a full end-to-end cloud deployment — the same style of architecture used by real-world companies running Kubernetes at scale.
