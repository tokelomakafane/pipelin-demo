@echo off
echo ===============================================
echo SIMPLE DOCKER BUILD AND TEST
echo ===============================================
echo.

echo [1] Checking required files...
if not exist "index.html" (
    echo ❌ index.html missing
    exit /b 1
)
echo ✅ index.html found

if not exist "nginx.conf" (
    echo ❌ nginx.conf missing  
    exit /b 1
)
echo ✅ nginx.conf found

if not exist "Dockerfile" (
    echo ❌ Dockerfile missing
    exit /b 1
)
echo ✅ Dockerfile found

echo.
echo [2] Building Docker image...
docker build -t thuto-html:latest .

if %errorlevel% neq 0 (
    echo ❌ Docker build failed
    echo.
    echo Troubleshooting:
    echo - Make sure Docker Desktop is running
    echo - Check if you're in the correct directory
    echo - Try: docker system prune -f
    exit /b 1
)

echo ✅ Docker build successful!
echo.

echo [3] Running container...
echo Starting on http://localhost:8080
echo Press Ctrl+C to stop the container
echo.

docker run --rm -p 8080:8080 thuto-html:latest
