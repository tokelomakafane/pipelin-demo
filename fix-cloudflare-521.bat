@echo off
echo.
echo ===============================================
echo   ☁️ Cloudflare Error 521 Troubleshooting
echo   demo.thuto.co.ls - Web server is down
echo ===============================================
echo.

echo 🔍 Error 521 means Cloudflare can reach your domain but your web server isn't responding.
echo Let's check your Kubernetes deployment step by step...
echo.

REM Check kubectl availability
kubectl version --client >nul 2>&1
if errorlevel 1 (
    echo ❌ kubectl is not available
    echo Please make sure kubectl is installed and KUBECONFIG is set
    pause
    exit /b 1
)

echo ✅ kubectl is available
echo.

REM Test cluster connection
echo 🔍 Testing cluster connection...
kubectl cluster-info >nul 2>&1
if errorlevel 1 (
    echo ❌ Cannot connect to Kubernetes cluster
    echo Please check your kubeconfig and cluster status
    pause
    exit /b 1
)

echo ✅ Connected to cluster
echo.

echo 📊 STEP 1: Checking namespace and resources...
kubectl get namespace thuto >nul 2>&1
if errorlevel 1 (
    echo ❌ Namespace 'thuto' does not exist
    echo Creating namespace...
    kubectl apply -f k8s/namespace.yaml
) else (
    echo ✅ Namespace 'thuto' exists
)

echo.
echo 📊 STEP 2: Checking deployment status...
kubectl get deployments -n thuto
echo.

kubectl get deployment thuto-app -n thuto >nul 2>&1
if errorlevel 1 (
    echo ❌ Deployment 'thuto-app' not found
    echo.
    echo 🚀 Deploying application...
    kubectl apply -f k8s/
    echo.
    echo ⏳ Waiting for deployment to be ready...
    timeout /t 30 >nul
    kubectl get pods -n thuto
) else (
    echo ✅ Deployment 'thuto-app' exists
    echo.
    echo 📋 Deployment details:
    kubectl get deployment thuto-app -n thuto -o wide
)

echo.
echo 📊 STEP 3: Checking pod status...
kubectl get pods -n thuto
echo.

echo 📊 STEP 4: Checking services...
kubectl get services -n thuto -o wide
echo.

echo 📊 STEP 5: Checking ingress...
kubectl get ingress -n thuto -o wide
echo.

echo 📊 STEP 6: Checking nginx-ingress controller...
kubectl get pods -n ingress-nginx 2>nul
if errorlevel 1 (
    echo ❌ nginx-ingress controller not found
    echo.
    echo 🔧 Installing nginx-ingress controller...
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/do/deploy.yaml
    echo.
    echo ⏳ Waiting for ingress controller to be ready...
    timeout /t 60 >nul
    kubectl get pods -n ingress-nginx
) else (
    echo ✅ nginx-ingress controller found
    kubectl get services -n ingress-nginx
)

echo.
echo 📊 STEP 7: Checking if pods are running...
for /f "tokens=1" %%i in ('kubectl get pods -n thuto --no-headers 2^>nul') do (
    echo.
    echo 📋 Pod logs for %%i:
    kubectl logs -n thuto %%i --tail=10
    echo.
    echo 📋 Pod description for %%i:
    kubectl describe pod -n thuto %%i | findstr -i "ready\|status\|error\|image\|pull"
)

echo.
echo 📊 STEP 8: Testing internal connectivity...
set /p test_internal=Do you want to test internal app connectivity? (y/n): 
if /i "%test_internal%"=="y" (
    echo.
    echo 🌐 Starting port-forward to test internal connectivity...
    echo Visit http://localhost:8080 in your browser
    echo Press Ctrl+C to stop port-forward
    kubectl port-forward service/thuto-service -n thuto 8080:80
)

echo.
echo 📊 STEP 9: DNS and Cloudflare Configuration...
echo.
echo 🔍 Current LoadBalancer external IP:
kubectl get services -n ingress-nginx -o wide | findstr LoadBalancer

echo.
echo 💡 SOLUTION CHECKLIST:
echo.
echo ✅ Check your Cloudflare DNS settings:
echo    1. Go to Cloudflare dashboard for thuto.co.ls
echo    2. Check A record for 'demo' points to LoadBalancer IP above
echo    3. Make sure proxy status is 'DNS only' (grey cloud) temporarily
echo    4. Check SSL/TLS mode is 'Flexible' or 'Full'
echo.
echo ✅ Check your deployment:
echo    1. Pods should be Running (see above)
echo    2. Service should have ClusterIP
echo    3. Ingress should have an ADDRESS
echo    4. nginx-ingress controller should be running
echo.
echo ✅ If pods are not running:
echo    1. Check pod logs above for errors
echo    2. Check if Docker image exists in GHCR
echo    3. Verify GitHub Actions completed successfully
echo.
echo 🚀 Quick fixes to try:
echo    kubectl rollout restart deployment/thuto-app -n thuto
echo    kubectl delete pods -n thuto --all  (to force recreation)
echo.
pause
