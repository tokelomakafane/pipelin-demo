# Thuto Django Application - Deployment Guide

## 🚀 Complete CI/CD Pipeline Setup Guide

This guide will walk you through setting up a complete CI/CD pipeline for the Thuto Django application.

### 📋 Prerequisites

Before you begin, ensure you have:

- [ ] GitHub account
- [ ] DigitalOcean account
- [ ] Docker installed locally
- [ ] kubectl installed
- [ ] Python 3.11+ installed
- [ ] Git installed

### 🏗️ Project Structure

Your project now includes:

```
pipelin-demo/
├── 🐍 Django Application
│   ├── thuto_project/          # Django settings
│   ├── thuto_app/              # Main app with welcome view
│   └── templates/              # HTML templates
├── 🐳 Docker Configuration
│   ├── Dockerfile              # Container definition
│   └── docker-compose.yml      # Local development
├── ☸️ Kubernetes Manifests
│   └── k8s/                    # K8s deployment files
├── 🔄 CI/CD Pipeline
│   └── .github/workflows/      # GitHub Actions
└── 📚 Documentation & Scripts
```

## 🛠️ Step-by-Step Setup

### Step 1: Local Development Setup

1. **Clone your repository**
   ```bash
   git clone https://github.com/tokelomakafane/pipelin-demo.git
   cd pipelin-demo
   ```

2. **Set up virtual environment (Windows)**
   ```cmd
   python -m venv venv
   venv\Scripts\activate
   pip install -r requirements.txt
   ```

3. **Run Django migrations**
   ```cmd
   python manage.py migrate
   ```

4. **Test the application**
   ```cmd
   python manage.py test
   python manage.py runserver
   ```

   Visit `http://localhost:8000` - you should see "Welcome to Thuto!"

### Step 2: GitHub Setup

1. **Create a new repository on GitHub**
   - Name: `pipelin-demo` (or your preferred name)
   - Make it public for GHCR access

2. **Push your code**
   ```bash
   git init
   git add .
   git commit -m "Initial commit: Thuto Django app with CI/CD pipeline"
   git branch -M main
   git remote add origin git@github.com:tokelomakafane/pipelin-demo.git
   git push -u origin main
   ```

3. **Enable GitHub Container Registry**
   - Go to your repository Settings
   - Navigate to Actions → General
   - Under "Workflow permissions", select "Read and write permissions"

### Step 3: DigitalOcean Kubernetes Setup

1. **Create a Kubernetes cluster**
   - Log in to DigitalOcean
   - Go to Kubernetes section
   - Create a new cluster (recommended: 2-3 nodes, 2GB RAM each)
   - Wait for cluster to be ready

2. **Download kubeconfig**
   - In your cluster dashboard, click "Download Config File"
   - Save it securely (you'll need it for GitHub Actions)

3. **Install nginx-ingress (recommended)**
   ```bash
   kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/do/deploy.yaml
   ```

4. **Install cert-manager for SSL (optional)**
   ```bash
   kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.yaml
   ```

### Step 4: Configure GitHub Secrets

This step is crucial! GitHub Actions needs access to your Kubernetes cluster to deploy your application.

Go to your repository → Settings → Secrets and variables → Actions

Add the following secrets:

1. **KUBECONFIG** - This tells GitHub Actions how to connect to your DigitalOcean Kubernetes cluster

   **What is KUBECONFIG?**
   - It's a configuration file that contains cluster connection details
   - You downloaded this file from DigitalOcean in Step 3
   - It needs to be encoded in base64 format for GitHub secrets

   **For Windows users:**
   ```powershell
   # Method 1: Using PowerShell (recommended)
   # Replace "path\to\your\kubeconfig" with actual path to downloaded file
   $content = Get-Content "C:\path\to\your\kubeconfig" -Raw
   [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($content))
   # Copy the output
   ```

   **For Linux/Mac users:**
   ```bash
   # Encode your kubeconfig file
   cat path/to/downloaded/kubeconfig | base64 -w 0
   # Copy the output
   ```

   **Alternative for Windows (using online tool):**
   - Open your kubeconfig file in notepad
   - Copy all the content
   - Go to https://www.base64encode.org/
   - Paste the content and click "Encode"
   - Copy the encoded result

   **How to add the secret:**
   1. In your GitHub repository, go to Settings
   2. Click "Secrets and variables" → "Actions"
   3. Click "New repository secret"
   4. Name: `KUBECONFIG`
   5. Value: Paste the base64 encoded content
   6. Click "Add secret"

   **⚠️ Important:** Keep this secret secure! It gives full access to your Kubernetes cluster.

### Step 5: Update Configuration Files

1. **✅ COMPLETED: Deployment image updated in `k8s/deployment.yaml`**
   ```yaml
   # This has been updated for your repository:
   image: ghcr.io/tokelomakafane/pipelin-demo:IMAGE_TAG
   ```
   **✨ This is already done for you!**

2. **✅ UPDATE SECRETS for demo.thuto.co.ls**
   
   **Easy way:** Run the provided script:
   ```cmd
   generate-secrets.bat
   ```
   
   **Manual way (Windows PowerShell):**
   ```powershell
   # Generate Django secret key (run this once)
   $key = -join ((65..90) + (97..122) + (48..57) + (33,64,35,36,37,94,38,42,40,41,45,95,61,43) | Get-Random -Count 50 | ForEach {[char]$_})
   [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($key))
   
   # DEBUG=False
   [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("False"))
   
   # Your domain: demo.thuto.co.ls
   [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("demo.thuto.co.ls,www.demo.thuto.co.ls"))
   ```
   
   **💡 The script will automatically update `k8s/secrets.yaml` with these values!**

3. **✅ COMPLETED: Domain updated in `k8s/ingress.yaml`**
   ```yaml
   # This has been updated for your domain:
   # - demo.thuto.co.ls
   # - www.demo.thuto.co.ls
   ```
   **✨ This is already done for you!**

### Step 6: Deploy!

1. **Push your changes**
   ```bash
   git add .
   git commit -m "Configure deployment settings"
   git push origin main
   ```

2. **Watch the GitHub Actions workflow**
   - Go to your repository → Actions tab
   - You should see the CI/CD pipeline running
   - It will test, build, and deploy your application

3. **Verify deployment**
   ```bash
   # Connect to your cluster
   export KUBECONFIG=/path/to/your/kubeconfig
   
   # Check deployment status
   kubectl get pods -n thuto
   kubectl get services -n thuto
   kubectl get ingress -n thuto
   ```

### Step 7: Access Your Application

**Option 1: Port Forward (immediate access)**
```bash
kubectl port-forward service/thuto-service -n thuto 8080:80
# Visit http://localhost:8080
```

**Option 2: LoadBalancer (DigitalOcean)**
```bash
# Get external IP
kubectl get services -n thuto
# Use the EXTERNAL-IP to access your app
```

**Option 3: Custom Domain (if configured)**
- Point your domain A record to the LoadBalancer IP
- Wait for DNS propagation
- Access via your domain

## 🔧 Advanced Configuration

### Environment Variables

Update the following for production:

**In `k8s/secrets.yaml`:**
- `SECRET_KEY`: Generate a secure Django secret key
- `DEBUG`: Set to `False` for production
- `ALLOWED_HOSTS`: Your production domain(s)

### Scaling

**Manual scaling:**
```bash
kubectl scale deployment/thuto-app -n thuto --replicas=5
```

**Auto-scaling is configured** via HPA in `k8s/hpa.yaml`

### SSL/TLS

If using cert-manager, create a ClusterIssuer:

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@example.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
```

### Database (Production)

For production, consider using DigitalOcean Managed Database:

1. Create a PostgreSQL database
2. Update `settings.py` to use the database URL
3. Add database credentials to Kubernetes secrets

## 🚨 Troubleshooting

### Common Issues

1. **Image Pull Errors**
   - Ensure GHCR permissions are correct
   - Check if repository name matches in deployment.yaml

2. **Pod CrashLoopBackOff**
   ```bash
   kubectl logs -n thuto deployment/thuto-app
   # Check for Django configuration errors
   ```

3. **Ingress Not Working**
   - Verify nginx-ingress controller is running
   - Check DNS configuration
   - Ensure domain points to LoadBalancer IP

4. **GitHub Actions Failing**
   - Check if KUBECONFIG secret is properly set
   - Verify repository permissions for GHCR

### Useful Commands

```bash
# View application logs
kubectl logs -n thuto deployment/thuto-app -f

# Check all resources
kubectl get all -n thuto

# Describe a failing pod
kubectl describe pod -n thuto POD_NAME

# Execute into a pod
kubectl exec -it -n thuto POD_NAME -- /bin/bash

# Check HPA status
kubectl get hpa -n thuto

# Force rolling update
kubectl rollout restart deployment/thuto-app -n thuto
```

## 🎯 What You've Accomplished

✅ **Complete Django Application**
- Beautiful welcome page with "Welcome to Thuto!"
- Production-ready configuration
- Comprehensive tests

✅ **Docker Containerization**
- Multi-stage builds
- Security best practices
- Non-root user

✅ **CI/CD Pipeline**
- Automated testing
- Docker image building
- Container registry publishing
- Kubernetes deployment

✅ **Kubernetes Deployment**
- Namespace isolation
- Secret management
- Auto-scaling
- Health checks
- Load balancing

✅ **Production Features**
- SSL/TLS support
- Monitoring and logging
- Horizontal pod autoscaling
- Rolling updates
- Security configurations

## 🎉 Congratulations!

You now have a complete CI/CD pipeline that:

1. **Tests** your code automatically
2. **Builds** Docker images
3. **Publishes** to GitHub Container Registry
4. **Deploys** to DigitalOcean Kubernetes
5. **Scales** automatically based on traffic
6. **Provides** SSL encryption and monitoring

Your "Welcome to Thuto!" application is now running in a production-ready environment with enterprise-grade DevOps practices!

## 📚 Next Steps

- Set up monitoring with Prometheus/Grafana
- Implement database backups
- Add logging aggregation
- Set up alerting
- Implement blue-green deployments
- Add more comprehensive tests

Happy learning! 🎓
