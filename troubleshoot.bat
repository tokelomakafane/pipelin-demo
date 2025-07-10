@echo off
echo.
echo ===============================================
echo   🔍 Kubernetes Deployment Troubleshooting
echo ===============================================
echo.

REM Check if kubectl is available
kubectl version --client >nul 2>&1
if errorlevel 1 (
    echo ❌ kubectl is not installed or not in PATH
    echo Please install kubectl and make sure your KUBECONFIG is set
    pause
    exit /b 1
)

echo ✅ kubectl is available
echo.

REM Check if we can connect to cluster
echo 🔍 Testing cluster connection...
kubectl cluster-info >nul 2>&1
if errorlevel 1 (
    echo ❌ Cannot connect to Kubernetes cluster
    echo.
    echo 📝 Possible solutions:
    echo 1. Make sure your kubeconfig is properly set
    echo 2. Check if your DigitalOcean cluster is running
    echo 3. Verify KUBECONFIG environment variable or --kubeconfig flag
    echo.
    set /p retry=Do you want to try connecting with a specific kubeconfig file? (y/n): 
    if /i "%retry%"=="y" (
        set /p kubepath=Enter path to your kubeconfig file: 
        echo Testing connection with !kubepath!...
        kubectl --kubeconfig="!kubepath!" cluster-info
    )
    pause
    exit /b 1
)

echo ✅ Connected to cluster
echo.

echo 📊 Current cluster info:
kubectl cluster-info
echo.

echo 🔍 Checking namespaces...
kubectl get namespaces
echo.

echo 🔍 Checking if 'thuto' namespace exists...
kubectl get namespace thuto >nul 2>&1
if errorlevel 1 (
    echo ❌ Namespace 'thuto' does not exist
    echo.
    set /p create=Do you want to create the namespace now? (y/n): 
    if /i "%create%"=="y" (
        echo Creating namespace...
        kubectl apply -f k8s/namespace.yaml
        if errorlevel 1 (
            echo ❌ Failed to create namespace
            echo Make sure k8s/namespace.yaml exists
        ) else (
            echo ✅ Namespace created successfully
        )
    )
) else (
    echo ✅ Namespace 'thuto' exists
)

echo.
echo 🔍 Checking resources in thuto namespace...
kubectl get all -n thuto
echo.

echo 🔍 Checking if thuto-app deployment exists...
kubectl get deployment thuto-app -n thuto >nul 2>&1
if errorlevel 1 (
    echo ❌ Deployment 'thuto-app' does not exist
    echo.
    echo 🛠️ Let's check what Kubernetes resources we have:
    
    echo.
    echo 📁 Available Kubernetes manifests:
    if exist "k8s\deployment.yaml" (
        echo ✅ k8s/deployment.yaml
    ) else (
        echo ❌ k8s/deployment.yaml - MISSING!
    )
    
    if exist "k8s\service.yaml" (
        echo ✅ k8s/service.yaml
    ) else (
        echo ❌ k8s/service.yaml - MISSING!
    )
    
    if exist "k8s\secrets.yaml" (
        echo ✅ k8s/secrets.yaml
    ) else (
        echo ❌ k8s/secrets.yaml - MISSING!
    )
    
    echo.
    set /p deploy=Do you want to deploy all Kubernetes resources now? (y/n): 
    if /i "%deploy%"=="y" (
        echo.
        echo 🚀 Deploying all resources...
        kubectl apply -f k8s/
        if errorlevel 1 (
            echo ❌ Deployment failed - check the error messages above
        ) else (
            echo ✅ Resources deployed successfully!
            echo.
            echo 📊 Current status:
            kubectl get all -n thuto
        )
    )
) else (
    echo ✅ Deployment 'thuto-app' exists
    echo.
    echo 📊 Deployment status:
    kubectl get deployment thuto-app -n thuto
    echo.
    echo 📊 Pod status:
    kubectl get pods -n thuto
    echo.
    echo 📋 Recent logs from thuto-app:
    kubectl logs -n thuto deployment/thuto-app --tail=20
)

echo.
echo 💡 Next steps:
echo.
echo If deployment doesn't exist:
echo   1. Make sure you've pushed your code to GitHub
echo   2. Check GitHub Actions is running: https://github.com/tokelomakafane/pipelin-demo/actions
echo   3. Verify KUBECONFIG secret is set in GitHub repository settings
echo.
echo If deployment exists but pods are failing:
echo   1. Check pod logs: kubectl logs -n thuto POD_NAME
echo   2. Describe pod: kubectl describe pod -n thuto POD_NAME
echo   3. Check secrets: kubectl get secrets -n thuto
echo.
echo Manual deployment commands:
echo   kubectl apply -f k8s/namespace.yaml
echo   kubectl apply -f k8s/secrets.yaml
echo   kubectl apply -f k8s/configmap.yaml
echo   kubectl apply -f k8s/deployment.yaml
echo   kubectl apply -f k8s/service.yaml
echo.
pause
