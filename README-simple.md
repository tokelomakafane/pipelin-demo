# Thuto - Simple HTML CI/CD Demo

A **simple, beautiful HTML page** demonstrating a complete CI/CD pipeline with Docker, Kubernetes, and DigitalOcean.

## 🌟 What's This?

This project showcases a **minimal yet professional** setup that's perfect for learning DevOps concepts without Django complexity:

- ✨ **Beautiful responsive HTML page** with modern CSS
- 🐳 **Lightweight Docker container** (nginx alpine)
- ☸️ **Kubernetes deployment** with health checks
- 🔄 **GitHub Actions CI/CD** pipeline
- 🌐 **Public access** via demo.thuto.co.ls

## 🚀 Quick Start

### Option 1: Deploy Simple HTML App (Recommended)
```cmd
debug-menu.bat
# Choose option 3: Deploy simple HTML app
```

### Option 2: Test Locally First
```cmd
test-local.bat
# This will build and run the Docker container locally
# Visit http://localhost:8080 to see the app
```

### Option 3: Manual Deployment
```cmd
deploy-simple.bat
# Clean deployment of the HTML app
```

## 📁 Project Structure

```
pipelin-demo/
├── index.html              # Beautiful welcome page
├── nginx.conf              # Nginx configuration  
├── Dockerfile              # Simple nginx container
├── k8s/                    # Kubernetes manifests
│   ├── deployment.yaml     # App deployment
│   ├── service.yaml        # Service definition
│   └── ingress-fixed.yaml  # Ingress for demo.thuto.co.ls
├── .github/workflows/      # CI/CD pipeline
└── scripts/                # Deployment & debug scripts
```

## 🎯 Features

### Beautiful HTML Page
- Modern, responsive design
- CSS animations and gradients
- Mobile-friendly layout
- System status indicator
- Professional appearance

### Production-Ready Setup
- Health checks (`/health` endpoint)
- Security headers
- Non-root container user
- Resource limits
- Rolling deployments

### Easy Debugging
- Interactive debug menu (`debug-menu.bat`)
- Local testing with Docker
- Step-by-step deployment
- Comprehensive troubleshooting scripts

## 🔧 Deployment Options

### 1. Simple HTML (Current Setup)
- **Technology**: HTML + CSS + JavaScript + nginx
- **Resources**: 32Mi RAM, 50m CPU
- **Startup**: ~5 seconds
- **Debugging**: Very easy
- **Perfect for**: Learning, demos, static sites

### 2. Django (Previous Setup - Archived)
- More complex but feature-rich
- Requires database, migrations, etc.
- Higher resource requirements
- Longer startup times

## 🌐 Accessing Your App

### Local Development
```cmd
test-local.bat
# Runs container locally on http://localhost:8080
```

### Kubernetes (Port Forward)
```cmd
kubectl port-forward svc/thuto-service 8080:80 -n thuto
# Access via http://localhost:8080
```

### Public Access
Once deployed: **https://demo.thuto.co.ls**

## 🛠️ Troubleshooting

Use the interactive debug menu:
```cmd
debug-menu.bat
```

**Common Issues & Quick Fixes:**
- **Pods Pending**: Resource constraints → Use minimal deployment
- **ImagePullBackOff**: Wrong image tag → GitHub Actions not run
- **Cloudflare 521**: DNS/ingress issues → Check LoadBalancer IP

**Available Scripts:**
- `emergency-fix.bat` - Quick diagnosis
- `deploy-simple.bat` - Clean HTML deployment  
- `test-local.bat` - Local Docker testing
- `quick-fix-*.bat` - Specific issue fixes

## ✅ Success Criteria

Your deployment is successful when:
1. ✅ Pods show "Running" status
2. ✅ Health check returns "healthy"
3. ✅ Local port-forward shows the welcome page
4. ✅ Public URL resolves (if DNS configured)

## 🎓 Learning Outcomes

This project teaches:
- Docker containerization
- Kubernetes deployments
- CI/CD with GitHub Actions  
- Container registries (GHCR)
- Ingress and DNS configuration
- Production troubleshooting
- Infrastructure as Code

**Much simpler than Django but still production-ready!**
