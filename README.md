# 🚀 Production-Grade WordPress on AWS EKS

A fully scalable, fault-tolerant, production-grade WordPress application deployed on **Amazon EKS**, backed by:

* **EFS (Elastic File System)** for RWX shared storage
* **RDS (MySQL)** as a managed database
* **AWS Load Balancer Controller + ALB** for ingress
* **Prometheus + Grafana** for complete monitoring and alerting
* **Nginx** reverse-proxy test configuration
* **Helm-based deployment workflows**

This project was completed as part of the **Syfe Infra Intern Assignment**.

---

## 📐 Architecture Overview

```
                    ┌──────────────────────────┐
                    │        End Users          │
                    └──────────────┬───────────┘
                                   │
                          Internet / ALB
                                   │
                      AWS ALB Ingress Controller
                                   │
                      ┌────────────┴────────────┐
                      │                         │
           WordPress Deployment           Nginx Reverse Proxy (Test)
                      │                         │
                      └──────────────┬──────────┘
                                     │
                             EFS Shared Storage (RWX)
                                     │
                               /bitnami/wordpress
                                     │
                                 WordPress Pods
                                     │
                                     ▼
                                Amazon RDS
                          (Managed MySQL Database)
```

---

## ✨ Key Features

### 🔹 **High Availability & Scalability**

* WordPress pods run on **EKS (managed Kubernetes)**.
* Content stored on **EFS**, allowing multiple pods to share the same data (**RWX**).

### 🔹 **Secure, Persistent Backend**

* Database hosted on **AWS RDS**.
* Kubernetes secrets store DB credentials.

### 🔹 **Production-Safe Ingress**

* ALB created via **AWS Load Balancer Controller**.
* Public access using HTTP (HTTPS-ready).

### 🔹 **Full Visibility with Monitoring**

* **Prometheus** scrapes cluster + application metrics.
* **Grafana** dashboards for:

  * WordPress pod CPU usage
  * Nginx request count
  * Nginx 5xx errors
  * Node metrics
  * Kubernetes cluster health

### 🔹 **Dynamic Storage Provisioning**

* EFS CSI driver dynamically provisions PVCs for scalable shared storage.

---

## 📂 Repository Structure

```
production-grade-wordpress-app/
│
├── alb-install/                     # IAM policies for ALB controller
├── phase2-efs/                      # EFS PVC tests + working manifests
├── k8s-backups/                     # Old YAML backups from debugging
├── terraform/                       # AWS IaC (EKS, VPC, RDS) - optional
│
├── wordpress-alb-ingress-http.yaml              # Initial ingress
├── wordpress-alb-ingress-http-fixed.yaml        # Fixed ALB forward rule
├── wordpress-values.yaml                         # Helm values override
│
├── pv-efs-wordpress-ap.yaml                     # Old static PV (testing)
├── pvc-efs-wordpress.yaml                       # EFS PVC manifest
├── efs-test-pvc*.yaml                            # EFS PVC connectivity tests
│
├── nginx-test.yaml                               # Test Nginx Deployment
├── nginx-test-ingress.yaml                       # Nginx ingress with ALB
│
├── trust-policy-alb.json                         # IAM trust policy
├── LICENSE.txt
├── README.md                                     # (You are reading this)
└── screenshots/                                  # Evidence images for video
```

---

# 🚀 Deployment Guide (Step-by-Step)

## ## 1️⃣ Prerequisites

* AWS account
* kubectl configured
* EKS cluster running
* IAM OIDC provider enabled
* AWS Load Balancer Controller installed
* EFS CSI Driver installed

---

## 2️⃣ Create StorageClass for EFS (if not created via Helm)

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: efs-sc
provisioner: efs.csi.aws.com
parameters:
  provisioningMode: efs-ap
  fileSystemId: <EFS-ID>
  directoryPerms: "755"
```

Apply:

```bash
kubectl apply -f storageclass-efs.yaml
```

---

## 3️⃣ Create WordPress Persistent Volume Claim

(from `phase2-efs/wordpress-pvc.yaml`)

```bash
kubectl apply -f phase2-efs/wordpress-pvc.yaml
kubectl get pvc -n wordpress
```

Expect: **STATUS = Bound**

---

## 4️⃣ Deploy WordPress using Helm (Bitnami)

```
helm install my-wordpress bitnami/wordpress -f wordpress-values.yaml -n wordpress
```

Check:

```
kubectl get pods -n wordpress
```

Should show: **Running**

---

## 5️⃣ Configure ALB Ingress

Apply the fixed ingress manifest:

```bash
kubectl apply -f wordpress-alb-ingress-http-fixed.yaml
```

Check ALB status:

```bash
kubectl get ingress -n wordpress
```

Copy ALB DNS name and open:

```
http://<ALB-DNS>/
http://<ALB-DNS>/wp-login.php
```

---

# 📊 Monitoring Setup

## 1️⃣ Install Prometheus & Grafana (Helm)

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/prometheus
helm install grafana grafana/grafana
```

## 2️⃣ Access Prometheus

```
kubectl port-forward svc/prometheus-server 9090:80
```

Metrics verified:

* `container_cpu_usage_seconds_total`
* `nginx_http_requests_total`
* `nginx_http_requests_total{status=~"5.."}`
* `node_memory_Active_bytes`

## 3️⃣ Access Grafana

```
kubectl port-forward svc/grafana 3000:80
```

Dashboards included:

* WordPress resource dashboard
* Kubernetes cluster dashboard
* Nginx request dashboard

---

# 🧹 Cleanup

```bash
helm uninstall my-wordpress -n wordpress
kubectl delete pvc wordpress-efs-pvc -n wordpress

helm uninstall prometheus
helm uninstall grafana
```

---

# 🖼 Screenshots (placed in `/screenshots`)

Include:

* EKS nodes Healthy
* PVC Bound
* PV Created
* ALB created
* WordPress login page
* RDS connectivity
* Prometheus targets: UP
* Grafana dashboards

---

# 🏁 Final Output

✔ Public WordPress site accessible via ALB
✔ WordPress login at `/wp-login.php`
✔ Database connectivity to RDS verified
✔ EFS dynamic provisioning working
✔ Prometheus scraping cluster/app metrics
✔ Grafana dashboards showing real-time insights

---
