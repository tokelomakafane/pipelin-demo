@echo off
echo.
echo ===============================================
echo   🚀 QUICK FIX for Pending Pods
echo ===============================================
echo.

echo Current status:
kubectl get pods -n thuto
echo.

echo 🔧 Applying quick fixes...
echo.

echo 1. Scaling down to 1 replica...
kubectl scale deployment/thuto-app -n thuto --replicas=1

echo.
echo 2. Reducing resource requests...
kubectl patch deployment thuto-app -n thuto -p "{\"spec\":{\"template\":{\"spec\":{\"containers\":[{\"name\":\"thuto-app\",\"resources\":{\"requests\":{\"memory\":\"64Mi\",\"cpu\":\"50m\"},\"limits\":{\"memory\":\"128Mi\",\"cpu\":\"100m\"}}}]}}}}"

echo.
echo 3. Deleting pending pods...
kubectl delete pods -n thuto --field-selector=status.phase=Pending

echo.
echo ⏳ Waiting 60 seconds for new pods to start...
timeout /t 60 >nul

echo.
echo 📊 New status:
kubectl get pods -n thuto
echo.

echo 🔍 If still pending, checking nodes:
kubectl get nodes
echo.

echo 💡 If pods are now running, test with:
echo kubectl port-forward service/thuto-service -n thuto 8080:80
echo.
pause
