@echo off
echo.
echo ===============================================
echo   🐳 Fix ImagePullBackOff Issue
echo   Container image cannot be pulled from GHCR
echo ===============================================
echo.

echo 📊 Current pod status:
kubectl get pods -n thuto
echo.

echo 🔍 Checking image pull errors...
echo.
for /f "tokens=1" %%i in ('kubectl get pods -n thuto --no-headers -o custom-columns=NAME:.metadata.name 2^>nul') do (
    echo 📋 Checking pod %%i:
    kubectl describe pod %%i -n thuto | findstr -i "image\|pull\|error\|failed\|backoff"
    echo.
)

echo 🔍 PROBLEM ANALYSIS:
echo ImagePullBackOff means Kubernetes cannot download your Docker image.
echo This usually happens when:
echo 1. Image doesn't exist in GitHub Container Registry (GHCR)
echo 2. GitHub Actions build failed
echo 3. Wrong image name/tag in deployment
echo 4. GHCR permissions issue
echo.

echo 📊 Checking GitHub Actions status...
echo Go to: https://github.com/tokelomakafane/pipelin-demo/actions
echo Check if the latest workflow completed successfully.
echo.

echo 📊 Checking GHCR repository...
echo Go to: https://github.com/tokelomakafane/pipelin-demo/pkgs/container/pipelin-demo
echo Check if container images exist.
echo.

set /p check_actions=Have you checked that GitHub Actions completed successfully? (y/n): 
if /i "%check_actions%"=="n" (
    echo.
    echo 🚀 SOLUTION: Push your code to trigger GitHub Actions build:
    echo.
    echo   git add .
    echo   git commit -m "Trigger image build"
    echo   git push origin main
    echo.
    echo Then wait for GitHub Actions to complete and run this script again.
    pause
    exit /b 0
)

echo.
echo 🔧 TRYING FIXES:
echo.

echo 1. Trying with 'latest' tag...
kubectl patch deployment thuto-app -n thuto -p "{\"spec\":{\"template\":{\"spec\":{\"containers\":[{\"name\":\"thuto-app\",\"image\":\"ghcr.io/tokelomakafane/pipelin-demo:latest\"}]}}}}"

echo.
echo ⏳ Waiting 30 seconds for image pull...
timeout /t 30 >nul

echo.
echo 📊 Status after 'latest' tag:
kubectl get pods -n thuto
echo.

REM Check if any pods are running
kubectl get pods -n thuto | findstr Running >nul
if not errorlevel 1 (
    echo ✅ SUCCESS! Pods are now running with 'latest' tag.
    goto :test_connectivity
)

echo 2. Trying with 'main' tag...
kubectl patch deployment thuto-app -n thuto -p "{\"spec\":{\"template\":{\"spec\":{\"containers\":[{\"name\":\"thuto-app\",\"image\":\"ghcr.io/tokelomakafane/pipelin-demo:main\"}]}}}}"

echo.
echo ⏳ Waiting 30 seconds for image pull...
timeout /t 30 >nul

echo.
echo 📊 Status after 'main' tag:
kubectl get pods -n thuto
echo.

REM Check if any pods are running
kubectl get pods -n thuto | findstr Running >nul
if not errorlevel 1 (
    echo ✅ SUCCESS! Pods are now running with 'main' tag.
    goto :test_connectivity
)

echo 3. Trying public image for testing...
kubectl patch deployment thuto-app -n thuto -p "{\"spec\":{\"template\":{\"spec\":{\"containers\":[{\"name\":\"thuto-app\",\"image\":\"python:3.11-slim\",\"command\":[\"python\",\"-c\",\"import time; print('Hello from Thuto!'); time.sleep(3600)\"]}]}}}}"

echo.
echo ⏳ Waiting 30 seconds for image pull...
timeout /t 30 >nul

echo.
echo 📊 Status after public image:
kubectl get pods -n thuto
echo.

:test_connectivity
kubectl get pods -n thuto | findstr Running >nul
if not errorlevel 1 (
    echo.
    echo 🎉 PODS ARE RUNNING!
    echo.
    set /p test_port=Do you want to test connectivity with port-forward? (y/n): 
    if /i "%test_port%"=="y" (
        echo.
        echo 🌐 Starting port-forward...
        echo Visit http://localhost:8080 in your browser
        echo Press Ctrl+C to stop port-forward
        kubectl port-forward service/thuto-service -n thuto 8080:80
    )
) else (
    echo.
    echo ❌ STILL HAVING ISSUES
    echo.
    echo 💡 MANUAL STEPS NEEDED:
    echo.
    echo 1. Check GitHub Actions:
    echo    https://github.com/tokelomakafane/pipelin-demo/actions
    echo.
    echo 2. If Actions failed, check workflow file:
    echo    .github/workflows/ci-cd.yml
    echo.
    echo 3. If no Actions ran, push code to trigger build:
    echo    git add . && git commit -m "Trigger build" && git push origin main
    echo.
    echo 4. Check GHCR packages:
    echo    https://github.com/tokelomakafane/pipelin-demo/pkgs/container/pipelin-demo
    echo.
    echo 5. If packages exist, check exact image name and tag in deployment:
    echo    kubectl get deployment thuto-app -n thuto -o yaml ^| findstr image
    echo.
)

echo.
pause
