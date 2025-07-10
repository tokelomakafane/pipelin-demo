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

**Option 3: Custom Domain with Cloudflare (demo.thuto.co.ls)**

**🔧 Cloudflare DNS Configuration:**
1. **Get your LoadBalancer IP:**
   ```bash
   kubectl get services -n ingress-nginx
   # Look for EXTERNAL-IP of the LoadBalancer service
   ```

2. **Configure Cloudflare DNS:**
   - Go to Cloudflare dashboard for thuto.co.ls
   - Add/Edit A record: `demo` → your LoadBalancer IP
   - Add/Edit A record: `www.demo` → your LoadBalancer IP
   - Set proxy status to "DNS only" (grey cloud) initially
   - SSL/TLS mode: "Flexible" or "Full"

3. **Test connectivity:**
   ```bash
   # Test internal connectivity first
   kubectl port-forward service/thuto-service -n thuto 8080:80
   # Visit http://localhost:8080
   
   # If internal works, check external
   nslookup demo.thuto.co.ls
   curl -I http://demo.thuto.co.ls
   ```

**🚨 Troubleshooting Cloudflare Error 521:**
- Run: `fix-cloudflare-521.bat`
- Check pod status: `kubectl get pods -n thuto`
- Check ingress: `kubectl get ingress -n thuto`
- Verify nginx-ingress controller is running

**Option 4: Direct LoadBalancer Access**
```bash
# Get external IP and test directly
kubectl get services -n ingress-nginx
# Access via http://EXTERNAL-IP
```

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

### 🔍 **FIRST: Check if your deployment exists**

If you get `error: deployments.apps "thuto-app" not found`, follow these steps:

```bash
# 1. Check if namespace exists
kubectl get namespaces | grep thuto

# 2. If namespace doesn't exist, create it first
kubectl apply -f k8s/namespace.yaml

# 3. Check what's in the thuto namespace
kubectl get all -n thuto

# 4. If nothing exists, deploy everything
kubectl apply -f k8s/

# 5. Watch the deployment process
kubectl get pods -n thuto -w
```

### Common Issues

1. **Image Pull Errors**
   ```bash
   # This means Kubernetes can't download your Docker image from GHCR
   
   # 1. Check the exact error
   kubectl describe pod -n thuto POD_NAME
   # Look for "Failed to pull image" or "repository does not exist"
   
   # 2. Check if image exists in GitHub Container Registry
   # Go to: https://github.com/tokelomakafane/pipelin-demo/pkgs/container/pipelin-demo
   
   # 3. Check GitHub Actions build status
   # Go to: https://github.com/tokelomakafane/pipelin-demo/actions
   
   # 4. Quick fix - use a working image tag
   kubectl patch deployment thuto-app -n thuto -p '{"spec":{"template":{"spec":{"containers":[{"name":"thuto-app","image":"ghcr.io/tokelomakafane/pipelin-demo:main-latest"}]}]}}}}'
   
   # 5. Or use latest tag if available
   kubectl patch deployment thuto-app -n thuto -p '{"spec":{"template":{"spec":{"containers":[{"name":"thuto-app","image":"ghcr.io/tokelomakafane/pipelin-demo:latest"}]}]}}}}'
   
   # 6. Check deployment status
   kubectl get pods -n thuto
   kubectl logs -n thuto deployment/thuto-app
   ```
   - Ensure GHCR permissions are correct
   - Check if repository name matches in deployment.yaml

2. **Pod CrashLoopBackOff**
   ```bash
   kubectl logs -n thuto deployment/thuto-app
   # Check for Django configuration errors
   ```

3. **Pods Stuck in "Pending" Status**
   ```bash
   # This means pods can't be scheduled - usually resource or node issues
   
   # 1. Check pod details for scheduling issues
   kubectl describe pods -n thuto
   # Look for "Events" section for scheduling errors
   
   # 2. Check node resources
   kubectl get nodes
   kubectl describe nodes
   
   # 3. Check if nodes have enough resources
   kubectl top nodes  # (if metrics-server is installed)
   
   # 4. Check resource requests in deployment
   kubectl get deployment thuto-app -n thuto -o yaml | grep -A 10 resources
   
   # 5. Quick fix - reduce resource requests
   kubectl patch deployment thuto-app -n thuto -p '{"spec":{"template":{"spec":{"containers":[{"name":"thuto-app","resources":{"requests":{"memory":"128Mi","cpu":"100m"},"limits":{"memory":"256Mi","cpu":"200m"}}}]}}}}'
   
   # 6. Scale down if needed
   kubectl scale deployment/thuto-app -n thuto --replicas=1
   ```

3. **Ingress Not Working**
   - Verify nginx-ingress controller is running
   - Check DNS configuration
   - Ensure domain points to LoadBalancer IP

4. **Cloudflare Error 521 "Web server is down"**
   ```bash
   # This means Cloudflare can reach your domain but your app isn't responding
   
   # 1. Check if your app is deployed
   kubectl get pods -n thuto
   kubectl get services -n thuto
   kubectl get ingress -n thuto
   
   # 2. Check pod status and logs
   kubectl describe pods -n thuto
   kubectl logs -n thuto deployment/thuto-app
   
   # 3. Check if LoadBalancer has external IP
   kubectl get services -n thuto -o wide
   
   # 4. Test internal connectivity
   kubectl port-forward service/thuto-service -n thuto 8080:80
   # Then visit http://localhost:8080
   
   # 5. Check ingress controller
   kubectl get pods -n ingress-nginx
   kubectl logs -n ingress-nginx deployment/ingress-nginx-controller
   ```

5. **GitHub Actions Failing**
   - Check if KUBECONFIG secret is properly set
   - Verify repository permissions for GHCR

### Useful Commands

```bash
# 🔍 TROUBLESHOOTING COMMANDS

# Check if deployment exists
kubectl get deployments -n thuto

# If deployment doesn't exist, create it manually
kubectl apply -f k8s/

# View application logs (if deployment exists)
kubectl logs -n thuto deployment/thuto-app -f

# If no deployment, check individual pods
kubectl get pods -n thuto
kubectl logs -n thuto POD_NAME

# Check all resources in namespace
kubectl get all -n thuto

# Describe a failing pod for detailed info
kubectl describe pod -n thuto POD_NAME

# Check if secrets are properly created
kubectl get secrets -n thuto

# Check if images can be pulled
kubectl describe pod -n thuto POD_NAME | grep -i image

# Execute into a pod (if running)
kubectl exec -it -n thuto POD_NAME -- /bin/bash

# Check HPA status
kubectl get hpa -n thuto

# Force rolling update
kubectl rollout restart deployment/thuto-app -n thuto

# 🚀 QUICK TROUBLESHOOTING SCRIPT
# Run: troubleshoot.bat
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
