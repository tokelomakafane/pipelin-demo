# Thuto Django Application

A simple Django application that displays "Welcome to Thuto" with a complete CI/CD pipeline using GitHub Actions, Docker, and Kubernetes deployment on DigitalOcean.

## Features

- 🎓 Simple Django application with a welcome page
- 🐳 Docker containerization
- 🔄 Complete CI/CD pipeline with GitHub Actions
- 📦 Container registry with GitHub Container Registry (GHCR)
- ☸️ Kubernetes deployment configuration
- 🌊 DigitalOcean Kubernetes integration
- 🔒 SSL/TLS support with cert-manager
- 📈 Horizontal Pod Autoscaling
- 🔧 Production-ready configuration

## Quick Start

### Local Development

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd pipelin-demo
   ```

2. **Set up virtual environment**
   ```bash
   python -m venv venv
   venv\Scripts\activate  # On Windows
   # source venv/bin/activate  # On Linux/Mac
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Run migrations**
   ```bash
   python manage.py migrate
   ```

5. **Start the development server**
   ```bash
   python manage.py runserver
   ```

Visit `http://localhost:8000` to see the welcome page.

### Using Docker

1. **Build and run with Docker Compose**
   ```bash
   docker-compose up --build
   ```

2. **Or build and run manually**
   ```bash
   docker build -t thuto-app .
   docker run -p 8000:8000 thuto-app
   ```

## Production Deployment

### Prerequisites

1. **GitHub Repository**
   - Fork or create a new repository
   - Enable GitHub Actions

2. **DigitalOcean Kubernetes Cluster**
   - Create a Kubernetes cluster on DigitalOcean
   - Download the kubeconfig file

3. **Domain (Optional)**
   - Configure your domain to point to your cluster

### Setup Steps

1. **Configure GitHub Secrets**
   
   Go to your repository Settings → Secrets and variables → Actions, and add:
   
   - `KUBECONFIG`: Base64 encoded kubeconfig file
     ```bash
     cat path/to/kubeconfig | base64 -w 0
     ```

2. **Update Kubernetes manifests**
   
   Edit the following files in the `k8s/` directory:
   
   - `deployment.yaml`: Update the image repository name
   - `ingress.yaml`: Replace `your-domain.com` with your actual domain
   - `secrets.yaml`: Update with your production secrets (base64 encoded)

3. **Update GitHub Actions workflow**
   
   In `.github/workflows/ci-cd.yml`, ensure the image name matches your repository.

4. **Deploy**
   
   Push to the `main` branch to trigger the CI/CD pipeline:
   ```bash
   git add .
   git commit -m "Initial deployment"
   git push origin main
   ```

### Manual Kubernetes Deployment

If you prefer to deploy manually:

1. **Build and push the Docker image**
   ```bash
   docker build -t ghcr.io/your-username/pipelin-demo:latest .
   docker push ghcr.io/your-username/pipelin-demo:latest
   ```

2. **Apply Kubernetes manifests**
   ```bash
   kubectl apply -f k8s/
   ```

3. **Check deployment status**
   ```bash
   kubectl get pods -n thuto
   kubectl get services -n thuto
   ```

## CI/CD Pipeline

The GitHub Actions workflow includes:

1. **Test Stage**
   - Runs Django tests
   - Performs Django system checks

2. **Build and Push Stage**
   - Builds Docker image
   - Pushes to GitHub Container Registry
   - Tags with commit SHA and latest

3. **Deploy Stage**
   - Updates Kubernetes deployment
   - Applies all manifests
   - Verifies deployment success

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Developer     │    │   GitHub Repo    │    │  GitHub Actions │
│                 │───▶│                  │───▶│                 │
│   git push      │    │   Source Code    │    │   CI/CD Pipeline│
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                                         │
                                                         ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│  DigitalOcean   │    │      GHCR        │    │   Docker Build  │
│   Kubernetes    │◀───│                  │◀───│                 │
│                 │    │  Container Reg.  │    │   & Push        │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## Environment Variables

### Development
- `DEBUG=True`
- `SECRET_KEY=django-insecure-dev-key`
- `ALLOWED_HOSTS=localhost,127.0.0.1`

### Production
- `DEBUG=False`
- `SECRET_KEY=<your-production-secret-key>`
- `ALLOWED_HOSTS=<your-domain.com>`

## Monitoring and Scaling

- **Health Checks**: Configured liveness and readiness probes
- **Auto Scaling**: HPA scales pods based on CPU and memory usage
- **Resource Limits**: Memory and CPU limits defined for each pod
- **SSL/TLS**: Automatic certificate management with cert-manager

## Security Features

- Non-root container user
- Secret management with Kubernetes secrets
- SSL/TLS encryption
- Environment-based configuration
- Security middleware enabled

## Project Structure

```
pipelin-demo/
├── .github/
│   └── workflows/
│       └── ci-cd.yml           # GitHub Actions workflow
├── k8s/                        # Kubernetes manifests
│   ├── namespace.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── configmap.yaml
│   ├── secrets.yaml
│   └── hpa.yaml
├── templates/
│   └── thuto_app/
│       └── welcome.html        # Welcome page template
├── thuto_app/                  # Django app
├── thuto_project/              # Django project settings
├── Dockerfile                  # Container configuration
├── docker-compose.yml          # Local development
├── requirements.txt            # Python dependencies
├── manage.py                   # Django management script
└── README.md                   # This file
```

## Troubleshooting

### Common Issues

1. **Image pull errors**
   - Ensure GHCR permissions are correctly set
   - Check if the image name matches in deployment.yaml

2. **Pod startup failures**
   - Check pod logs: `kubectl logs -n thuto <pod-name>`
   - Verify environment variables and secrets

3. **Ingress not working**
   - Ensure nginx-ingress controller is installed
   - Check if cert-manager is properly configured
   - Verify DNS settings for your domain

### Useful Commands

```bash
# Check pod status
kubectl get pods -n thuto

# View pod logs
kubectl logs -n thuto deployment/thuto-app

# Check service endpoints
kubectl get endpoints -n thuto

# Monitor HPA
kubectl get hpa -n thuto

# Check ingress
kubectl get ingress -n thuto
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is open source and available under the [MIT License](LICENSE).

## Support

For questions or issues, please open a GitHub issue or contact the maintainers.
"# pipelin-demo" 
