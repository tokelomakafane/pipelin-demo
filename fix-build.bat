@echo off
echo ===============================================
echo QUICK FIX FOR LOCAL DOCKER BUILD
echo ===============================================
echo.

echo [1] Cleaning up Docker cache...
docker system prune -f
echo.

echo [2] Testing HTML file...
if exist "index.html" (
    echo ✅ index.html exists
    echo Checking HTML content:
    findstr /C:"Welcome to" index.html >nul 2>&1
    if %errorlevel%==0 (
        echo ✅ Found "Welcome to" text
    ) else (
        echo ⚠️  "Welcome to" not found, checking for "Thuto"
        findstr /C:"Thuto" index.html >nul 2>&1
        if %errorlevel%==0 (
            echo ✅ Found "Thuto" text - HTML looks good
        ) else (
            echo ❌ HTML content validation failed
        )
    )
    echo File size: 
    dir index.html | findstr "index.html"
) else (
    echo ❌ index.html missing - this will cause build issues
    exit /b 1
)

echo.
echo [3] Testing nginx config...
if exist "nginx.conf" (
    echo ✅ nginx.conf exists
    echo Checking for port 8080:
    findstr "8080" nginx.conf
) else (
    echo ❌ nginx.conf missing
    exit /b 1
)

echo.
echo [4] Building with simplified Dockerfile...
echo Building image: thuto-simple:test
docker build -t thuto-simple:test . --no-cache

if %errorlevel%==0 (
    echo ✅ Docker build successful!
    echo.
    echo [5] Testing the container...
    echo Starting container on http://localhost:8080
    echo Press Ctrl+C to stop when done testing
    echo.
    
    docker run --rm -p 8080:8080 thuto-simple:test
) else (
    echo ❌ Docker build still failing
    echo.
    echo Troubleshooting steps:
    echo 1. Check if Docker Desktop is running
    echo 2. Make sure you're in the correct directory
    echo 3. Verify index.html and nginx.conf exist
    echo 4. Try: docker system prune -a
    echo.
    
    echo Current directory contents:
    dir *.html *.conf Dockerfile
    
    exit /b 1
)

echo.
echo ===============================================
echo BUILD COMPLETED SUCCESSFULLY!
echo ===============================================
