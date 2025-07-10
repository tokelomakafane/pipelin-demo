@echo off
echo.
echo ===============================================
echo   ⏳ Fix Pending Pods Issue
echo   thuto-app pods stuck in Pending status
echo ===============================================
echo.

echo 🔍 Pods in "Pending" status means they can't be scheduled.
echo This is usually due to insufficient cluster resources.
echo.

REM Check kubectl availability
kubectl version --client >nul 2>&1
if errorlevel 1 (
    echo ❌ kubectl is not available
    pause
    exit /b 1
)

echo ✅ kubectl is available
echo.

echo 📊 STEP 1: Current pod status...
kubectl get pods -n thuto
echo.

echo 📊 STEP 2: Detailed pod information...
echo.
for /f "tokens=1" %%i in ('kubectl get pods -n thuto --no-headers -o custom-columns=NAME:.metadata.name 2^>nul') do (
    echo 🔍 Describing pod %%i:
    kubectl describe pod %%i -n thuto | findstr -i "Events\|insufficient\|pending\|schedule\|resource\|memory\|cpu"
    echo.
)

echo 📊 STEP 3: Checking cluster nodes...
kubectl get nodes
echo.

echo 📊 STEP 4: Checking node resources...
kubectl describe nodes | findstr -i "cpu\|memory\|allocatable\|capacity"
echo.

echo 📊 STEP 5: Current deployment resource requests...
kubectl get deployment thuto-app -n thuto -o yaml | findstr -A 5 -B 5 "resources\|memory\|cpu"
echo.

echo 💡 COMMON SOLUTIONS:
echo.
echo 1. Reduce resource requests (most common fix)
echo 2. Scale down replicas temporarily  
echo 3. Add more nodes to cluster
echo.

set /p fix_resources=Do you want to reduce resource requests to fix pending pods? (y/n): 
if /i "%fix_resources%"=="y" (
    echo.
    echo 🔧 Reducing resource requests...
    kubectl patch deployment thuto-app -n thuto -p "{\"spec\":{\"template\":{\"spec\":{\"containers\":[{\"name\":\"thuto-app\",\"resources\":{\"requests\":{\"memory\":\"128Mi\",\"cpu\":\"100m\"},\"limits\":{\"memory\":\"256Mi\",\"cpu\":\"200m\"}}}]}}}}"
    
    if errorlevel 1 (
        echo ❌ Failed to patch deployment
    ) else (
        echo ✅ Resource requests reduced successfully!
        echo.
        echo ⏳ Waiting for pods to be scheduled...
        timeout /t 30 >nul
        
        echo 📊 New pod status:
        kubectl get pods -n thuto
    )
)

echo.
set /p scale_down=Do you want to scale down to 1 replica temporarily? (y/n): 
if /i "%scale_down%"=="y" (
    echo.
    echo 🔧 Scaling down to 1 replica...
    kubectl scale deployment/thuto-app -n thuto --replicas=1
    
    echo ⏳ Waiting for scaling...
    timeout /t 20 >nul
    
    echo 📊 New pod status:
    kubectl get pods -n thuto
)

echo.
set /p delete_pods=Do you want to delete pending pods to force recreation? (y/n): 
if /i "%delete_pods%"=="y" (
    echo.
    echo 🗑️ Deleting pending pods...
    kubectl delete pods -n thuto --field-selector=status.phase=Pending
    
    echo ⏳ Waiting for new pods...
    timeout /t 30 >nul
    
    echo 📊 New pod status:
    kubectl get pods -n thuto
)

echo.
echo 📊 FINAL STATUS:
kubectl get pods -n thuto
echo.

echo 💡 If pods are still pending:
echo.
echo 1. Check your DigitalOcean cluster has enough nodes:
echo    - Go to DigitalOcean → Kubernetes → Your Cluster
echo    - Check node pool has available capacity
echo    - Consider adding more nodes or upgrading node size
echo.
echo 2. Check for node taints or scheduling constraints:
echo    kubectl describe nodes ^| findstr -i "taint\|condition"
echo.
echo 3. Manually deploy with minimal resources:
echo    kubectl apply -f k8s/deployment.yaml
echo    kubectl patch deployment thuto-app -n thuto -p "{\"spec\":{\"replicas\":1}}"
echo.

echo 🚀 Once pods are running, test internal connectivity:
echo    kubectl port-forward service/thuto-service -n thuto 8080:80
echo    # Then visit http://localhost:8080
echo.
pause
