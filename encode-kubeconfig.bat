@echo off
echo.
echo =============================================
echo   🔐 KUBECONFIG Encoder for GitHub Secrets
echo =============================================
echo.

REM Check if PowerShell is available
powershell -Command "Get-Host" >nul 2>&1
if errorlevel 1 (
    echo ❌ PowerShell is not available
    echo Please use the manual method described in DEPLOYMENT_GUIDE.md
    pause
    exit /b 1
)

echo This script will help you encode your kubeconfig file for GitHub Secrets.
echo.

set /p kubepath=Enter the full path to your kubeconfig file: 

if not exist "%kubepath%" (
    echo ❌ File not found: %kubepath%
    echo Please check the path and try again.
    pause
    exit /b 1
)

echo.
echo 🔄 Encoding kubeconfig file...
echo.

REM Use PowerShell to encode the file
powershell -Command "$content = Get-Content '%kubepath%' -Raw; [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($content))" > encoded_kubeconfig.txt

if errorlevel 1 (
    echo ❌ Failed to encode the file
    pause
    exit /b 1
)

echo ✅ Kubeconfig encoded successfully!
echo.
echo 📋 The encoded content has been saved to: encoded_kubeconfig.txt
echo.
echo 📝 Next steps:
echo 1. Open encoded_kubeconfig.txt and copy all the content
echo 2. Go to your GitHub repository → Settings → Secrets and variables → Actions
echo 3. Click "New repository secret"
echo 4. Name: KUBECONFIG
echo 5. Value: Paste the copied content
echo 6. Click "Add secret"
echo.

set /p open=Do you want to open the encoded file now? (y/n): 
if /i "%open%"=="y" (
    notepad encoded_kubeconfig.txt
)

echo.
echo ⚠️  SECURITY WARNING:
echo Delete the encoded_kubeconfig.txt file after copying to GitHub!
echo This file contains sensitive cluster access credentials.
echo.

set /p delete=Delete the encoded file now? (y/n): 
if /i "%delete%"=="y" (
    del encoded_kubeconfig.txt
    echo ✅ File deleted successfully
)

echo.
echo 🎉 Done! Your KUBECONFIG secret is ready for GitHub Actions.
pause
