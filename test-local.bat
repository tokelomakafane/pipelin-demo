@echo off
echo ===============================================
echo TESTING SIMPLE HTML APP LOCALLY
echo ===============================================
echo.

echo [1] Testing if HTML file exists and is valid...
if exist "index.html" (
    echo ✅ index.html found
    findstr /C:"Welcome to" index.html >nul 2>&1
    if %errorlevel%==0 (
        echo ✅ HTML content looks good
    ) else (
        echo ❌ HTML content missing "Welcome to" text
        echo Checking for "Thuto" instead...
        findstr /C:"Thuto" index.html >nul 2>&1
        if %errorlevel%==0 (
            echo ✅ HTML content has "Thuto" - looks good
        ) else (
            echo ❌ HTML content validation failed
        )
    )
) else (
    echo ❌ index.html not found
    exit /b 1
)

echo.
echo [2] Testing nginx config...
if exist "nginx.conf" (
    echo ✅ nginx.conf found
    findstr /C:"listen 8080" nginx.conf >nul
    if %errorlevel%==0 (
        echo ✅ nginx config looks good
    ) else (
        echo ❌ nginx config incomplete
    )
) else (
    echo ❌ nginx.conf not found
    exit /b 1
)

echo.
echo [3] Building Docker image locally...
docker build -t thuto-simple:test .
if %errorlevel%==0 (
    echo ✅ Docker image built successfully
) else (
    echo ❌ Docker build failed
    exit /b 1
)

echo.
echo [4] Running container locally for testing...
echo Starting container on http://localhost:8080
echo Press Ctrl+C to stop the container
echo.

docker run --rm -p 8080:8080 thuto-simple:test

echo.
echo ===============================================
echo LOCAL TEST COMPLETED
echo ===============================================
