@echo off
echo ===============================================
echo EMERGENCY KUBERNETES TROUBLESHOOTING SCRIPT
echo ===============================================
echo.

echo [1] Checking pod status and details...
kubectl get pods -n thuto -o wide
echo.

echo [2] Describing problematic pods...
for /f "tokens=1" %%i in ('kubectl get pods -n thuto --no-headers') do (
    echo --- Describing pod %%i ---
    kubectl describe pod %%i -n thuto
    echo.
)

echo [3] Getting logs from running pods...
for /f "tokens=1" %%i in ('kubectl get pods -n thuto --no-headers ^| findstr Running') do (
    echo --- Logs from pod %%i ---
    kubectl logs %%i -n thuto --tail=20
    echo.
)

echo [4] Checking node resources...
kubectl top nodes
echo.

echo [5] Checking namespace events...
kubectl get events -n thuto --sort-by='.lastTimestamp'
echo.

echo [6] IMMEDIATE FIXES...
echo.

echo [6a] Scaling down to 1 replica for easier debugging...
kubectl scale deployment django-app -n thuto --replicas=1

echo [6b] Deleting all pending pods to force restart...
kubectl delete pods -n thuto --field-selector=status.phase=Pending

echo [6c] Checking if deployment uses correct image...
kubectl get deployment django-app -n thuto -o jsonpath='{.spec.template.spec.containers[0].image}'
echo.

echo [7] Waiting for new pod to start...
timeout /t 30 /nobreak
kubectl get pods -n thuto

echo.
echo ===============================================
echo NEXT STEPS:
echo 1. Check the logs above for error messages
echo 2. If you see "ImagePullBackOff", run: quick-fix-image.bat
echo 3. If pods are still Pending, run: quick-fix-pending.bat
echo 4. If Django app has errors, check the Django logs above
echo ===============================================
pause
