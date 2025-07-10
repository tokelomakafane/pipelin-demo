@echo off
echo ===============================================
echo SIMPLE HTML DEPLOYMENT - CLEAN SETUP
echo ===============================================
echo.

echo [STEP 1] Cleaning up Django deployment completely...
kubectl delete namespace thuto --force --grace-period=0
echo Waiting for namespace deletion...
timeout /t 20 /nobreak

echo.
echo [STEP 2] Creating fresh namespace...
kubectl create namespace thuto

echo.
echo [STEP 3] Deploying simple HTML application...
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress-fixed.yaml

echo.
echo [STEP 4] Waiting for deployment...
kubectl rollout status deployment/thuto-app -n thuto --timeout=300s

echo.
echo [STEP 5] Checking deployment status...
kubectl get all -n thuto
echo.

echo [STEP 6] Getting pod details...
kubectl get pods -n thuto -o wide
echo.

echo [STEP 7] Testing health endpoint...
timeout /t 10 /nobreak
for /f "tokens=1" %%i in ('kubectl get pods -n thuto --no-headers ^| findstr Running') do (
    echo Testing health check on %%i...
    kubectl exec %%i -n thuto -- wget -q -O- http://localhost:8080/health
    echo.
)

echo.
echo [STEP 8] Setting up port-forward for local testing...
echo.
echo Starting port-forward on http://localhost:8080
echo Press Ctrl+C to stop when done testing...
echo.
kubectl port-forward svc/thuto-service 8080:80 -n thuto

echo.
echo ===============================================
echo SIMPLE HTML APP DEPLOYED!
echo ===============================================
echo Local test: http://localhost:8080
echo Public URL: https://demo.thuto.co.ls (once DNS is configured)
echo Health check: http://localhost:8080/health
echo.
echo No more Django complexity!
echo - Just HTML + CSS + JavaScript
echo - Nginx web server
echo - Health checks working
echo - Minimal resource usage
echo ===============================================
