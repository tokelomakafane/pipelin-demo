@echo off
echo ===============================================
echo KUBERNETES DEPLOYMENT STATUS CHECK
echo ===============================================
echo.

echo [1] Checking namespace...
kubectl get namespaces | findstr thuto

echo.
echo [2] Checking all resources in thuto namespace...
kubectl get all -n thuto

echo.
echo [3] Checking pod status...
kubectl get pods -n thuto -o wide

echo.
echo [4] Checking deployment status...
kubectl get deployment thuto-app -n thuto

echo.
echo [5] Checking service...
kubectl get service thuto-service -n thuto

echo.
echo [6] Checking ingress...
kubectl get ingress thuto-ingress -n thuto

echo.
echo [7] If pods are running, testing health endpoint...
for /f "tokens=1" %%i in ('kubectl get pods -n thuto --no-headers ^| findstr Running') do (
    echo Testing health check on pod %%i...
    kubectl exec %%i -n thuto -- wget -q -O- http://localhost:8080/health 2>nul || echo Health check failed
)

echo.
echo [8] Port forward test (press Ctrl+C to stop)...
echo Starting port-forward to test the app locally...
echo Visit: http://localhost:8080
echo.
kubectl port-forward svc/thuto-service 8080:80 -n thuto

echo.
echo ===============================================
echo DEPLOYMENT STATUS CHECK COMPLETED
echo ===============================================
