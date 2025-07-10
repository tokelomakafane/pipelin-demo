@echo off
echo ===============================================
echo SYSTEMATIC KUBERNETES DEBUGGING GUIDE
echo ===============================================
echo.
echo This script will guide you through fixing your deployment step by step.
echo.

:MENU
echo.
echo Choose what to do:
echo 1. Emergency diagnosis (check current status)
echo 2. Complete reset with fixed configuration  
echo 3. Deploy simple HTML app (recommended)
echo 4. Test HTML app locally with Docker
echo 5. Quick fix for pending pods
echo 6. Quick fix for image pull errors
echo 7. Check application logs
echo 8. Test local connectivity
echo 9. Check ingress and DNS
echo 0. Exit
echo.

set /p choice="Enter your choice (0-9): "

if "%choice%"=="1" goto DIAGNOSIS
if "%choice%"=="2" goto RESET
if "%choice%"=="3" goto SIMPLE
if "%choice%"=="4" goto TESTLOCAL
if "%choice%"=="5" goto PENDING
if "%choice%"=="6" goto IMAGE
if "%choice%"=="7" goto LOGS
if "%choice%"=="8" goto LOCAL
if "%choice%"=="9" goto INGRESS
if "%choice%"=="0" goto EXIT
goto MENU

:DIAGNOSIS
echo.
echo ===============================================
echo EMERGENCY DIAGNOSIS
echo ===============================================
call emergency-fix.bat
goto MENU

:SIMPLE
echo.
echo ===============================================
echo DEPLOYING SIMPLE HTML APP (RECOMMENDED)
echo ===============================================
call deploy-simple.bat
goto MENU

:TESTLOCAL
echo.
echo ===============================================
echo TESTING HTML APP LOCALLY
echo ===============================================
call test-local.bat
goto MENU

:RESET
echo.
echo ===============================================
echo COMPLETE RESET WITH FIXED CONFIGURATION
echo ===============================================
call complete-reset.bat
goto MENU

:PENDING
echo.
echo ===============================================
echo FIXING PENDING PODS
echo ===============================================
call quick-fix-pending.bat
goto MENU

:IMAGE
echo.
echo ===============================================
echo FIXING IMAGE PULL ERRORS
echo ===============================================
call quick-fix-image.bat
goto MENU

:LOGS
echo.
echo ===============================================
echo CHECKING DJANGO LOGS
echo ===============================================
echo Getting logs from all running pods...
for /f "tokens=1" %%i in ('kubectl get pods -n thuto --no-headers ^| findstr Running') do (
    echo.
    echo --- Logs from %%i ---
    kubectl logs %%i -n thuto --tail=50
    echo.
)
echo.
echo Press any key to continue...
pause >nul
goto MENU

:LOCAL
echo.
echo ===============================================
echo TESTING LOCAL CONNECTIVITY
echo ===============================================
echo Starting port-forward to test Django app locally...
echo.
echo This will make your app available at http://localhost:8080
echo Press Ctrl+C to stop the port-forward when done testing.
echo.
kubectl port-forward svc/django-service 8080:80 -n thuto
goto MENU

:INGRESS
echo.
echo ===============================================
echo CHECKING INGRESS AND DNS
echo ===============================================
echo.
echo [1] Checking ingress controller...
kubectl get pods -n ingress-nginx
echo.
echo [2] Checking ingress resources...
kubectl get ingress -n thuto
echo.
echo [3] Describing ingress...
kubectl describe ingress django-ingress -n thuto
echo.
echo [4] Checking if demo.thuto.co.ls resolves...
nslookup demo.thuto.co.ls
echo.
echo Press any key to continue...
pause >nul
goto MENU

:EXIT
echo.
echo ===============================================
echo SUMMARY OF AVAILABLE OPTIONS:
echo ===============================================
echo RECOMMENDED (Simple HTML):
echo - deploy-simple.bat: Clean deployment with HTML app
echo - test-local.bat: Test HTML app locally with Docker
echo.
echo TROUBLESHOOTING:
echo - emergency-fix.bat: Quick diagnosis and immediate fixes
echo - complete-reset.bat: Clean slate deployment with fixed config  
echo - quick-fix-pending.bat: Fix pods stuck in Pending
echo - quick-fix-image.bat: Fix ImagePullBackOff errors
echo.
echo The simple HTML approach is much easier to deploy and debug!
echo No more Django complexity - just HTML + nginx.
echo ===============================================
exit /b 0
