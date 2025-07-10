@echo off
echo.
echo ===============================================
echo   🚀 QUICK FIX: ImagePullBackOff
echo ===============================================
echo.

echo 🔍 Current issue: IMAGE_TAG is not being replaced
echo Your deployment is trying to pull: ghcr.io/tokelomakafane/pipelin-demo:IMAGE_TAG
echo But that literal tag doesn't exist!
echo.

echo 🔧 Applying quick fix...
echo.

echo 1. Fixing image tag to 'latest'...
kubectl patch deployment thuto-app -n thuto -p "{\"spec\":{\"template\":{\"spec\":{\"containers\":[{\"name\":\"thuto-app\",\"image\":\"ghcr.io/tokelomakafane/pipelin-demo:latest\"}]}}}}"

echo.
echo 2. Scaling down pending pods...
kubectl scale deployment/thuto-app -n thuto --replicas=0
timeout /t 5 >nul
kubectl scale deployment/thuto-app -n thuto --replicas=1

echo.
echo ⏳ Waiting 45 seconds for new pod...
timeout /t 45 >nul

echo.
echo 📊 New status:
kubectl get pods -n thuto

echo.
echo 🔍 If still failing, trying 'main' tag...
kubectl get pods -n thuto | findstr Running >nul
if errorlevel 1 (
    kubectl patch deployment thuto-app -n thuto -p "{\"spec\":{\"template\":{\"spec\":{\"containers\":[{\"name\":\"thuto-app\",\"image\":\"ghcr.io/tokelomakafane/pipelin-demo:main\"}]}}}}"
    
    echo ⏳ Waiting 30 seconds...
    timeout /t 30 >nul
    
    kubectl get pods -n thuto
)

echo.
echo 💡 NEXT STEPS:
echo.
echo 1. If pods are running: Test with 'kubectl port-forward service/thuto-service -n thuto 8080:80'
echo 2. If still failing: Check https://github.com/tokelomakafane/pipelin-demo/actions
echo 3. No GitHub Actions runs: Push code to trigger build
echo.
pause
