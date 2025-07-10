@echo off
echo ===============================================
echo COMPLETE DEPLOYMENT RESET AND FIX
echo ===============================================
echo.

echo [STEP 1] Cleaning up existing problematic resources...
kubectl delete deployment --all -n thuto
kubectl delete service --all -n thuto  
kubectl delete ingress --all -n thuto
kubectl delete pods --all -n thuto --force --grace-period=0

echo.
echo [STEP 2] Waiting for cleanup...
timeout /t 15 /nobreak

echo.
echo [STEP 3] Applying corrected configurations...
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress-fixed.yaml

echo.
echo [STEP 4] Waiting for deployment to be ready...
kubectl rollout status deployment/django-app -n thuto --timeout=300s

echo.
echo [STEP 5] Checking final status...
kubectl get all -n thuto
echo.

echo [STEP 6] Getting pod details...
kubectl get pods -n thuto -o wide
echo.

echo [STEP 7] Checking logs...
timeout /t 10 /nobreak
for /f "tokens=1" %%i in ('kubectl get pods -n thuto --no-headers ^| findstr Running') do (
    echo --- Logs from %%i ---
    kubectl logs %%i -n thuto --tail=20
    echo.
)

echo.
echo ===============================================
echo DEPLOYMENT STATUS:
echo ===============================================
kubectl get deployment django-app -n thuto
kubectl get service django-service -n thuto  
kubectl get ingress django-ingress -n thuto

echo.
echo ===============================================
echo NEXT STEPS:
echo 1. If pods are Running, test locally: kubectl port-forward svc/django-service 8080:80 -n thuto
echo 2. Then visit: http://localhost:8080
echo 3. If working locally, check Cloudflare DNS settings for demo.thuto.co.ls
echo 4. Verify ingress controller is installed: kubectl get pods -n ingress-nginx
echo ===============================================
pause
