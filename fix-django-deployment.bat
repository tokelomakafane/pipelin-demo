@echo off
echo ===============================================
echo FIXING DJANGO DEPLOYMENT CONFIGURATION
echo ===============================================
echo.

echo [1] Current deployment configuration:
kubectl get deployment django-app -n thuto -o yaml > current-deployment.yaml
type current-deployment.yaml

echo.
echo [2] Patching deployment with safer configuration...

echo [2a] Removing health checks temporarily...
kubectl patch deployment django-app -n thuto --type=json -p="[{\"op\": \"remove\", \"path\": \"/spec/template/spec/containers/0/livenessProbe\"}, {\"op\": \"remove\", \"path\": \"/spec/template/spec/containers/0/readinessProbe\"}]"

echo [2b] Setting correct image...
kubectl patch deployment django-app -n thuto -p="{\"spec\":{\"template\":{\"spec\":{\"containers\":[{\"name\":\"django-app\",\"image\":\"ghcr.io/tokelomakafane/pipelin-demo:latest\"}]}}}}"

echo [2c] Adding debug environment variables...
kubectl patch deployment django-app -n thuto -p="{\"spec\":{\"template\":{\"spec\":{\"containers\":[{\"name\":\"django-app\",\"env\":[{\"name\":\"DEBUG\",\"value\":\"True\"},{\"name\":\"ALLOWED_HOSTS\",\"value\":\"*\"},{\"name\":\"DJANGO_SETTINGS_MODULE\",\"value\":\"thuto_project.settings\"}]}]}}}}"

echo [2d] Scaling to 1 replica for debugging...
kubectl scale deployment django-app -n thuto --replicas=1

echo.
echo [3] Waiting for rollout...
kubectl rollout status deployment/django-app -n thuto --timeout=300s

echo.
echo [4] Checking new pod status...
kubectl get pods -n thuto
kubectl describe pods -n thuto

echo.
echo [5] Getting logs from new pod...
timeout /t 10 /nobreak
for /f "tokens=1" %%i in ('kubectl get pods -n thuto --no-headers ^| findstr Running') do (
    echo --- Logs from %%i ---
    kubectl logs %%i -n thuto --tail=30
)

echo.
echo ===============================================
echo If the pod is still crashing, check the logs above for:
echo - Django configuration errors
echo - Missing environment variables
echo - Database connection issues
echo - Import/module errors
echo ===============================================
pause
