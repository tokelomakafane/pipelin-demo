@echo off
echo.
echo ==========================================
echo   🔐 Generate Secrets for demo.thuto.co.ls
echo ==========================================
echo.

REM Check if PowerShell is available
powershell -Command "Get-Host" >nul 2>&1
if errorlevel 1 (
    echo ❌ PowerShell is not available
    echo Please use the manual method or install PowerShell
    pause
    exit /b 1
)

echo 🔑 Generating base64 encoded secrets for your domain...
echo.

REM Generate a secure Django secret key
echo 📝 Generating Django SECRET_KEY...
powershell -Command "$chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*(-_=+)'; $key = ''; for($i=0; $i -lt 50; $i++) { $key += $chars[(Get-Random -Maximum $chars.Length)] }; [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($key))" > secret_key.txt

REM Generate DEBUG=False
echo 🐛 Generating DEBUG setting...
powershell -Command "[Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes('False'))" > debug.txt

REM Generate ALLOWED_HOSTS for your domain
echo 🌐 Generating ALLOWED_HOSTS for demo.thuto.co.ls...
powershell -Command "[Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes('demo.thuto.co.ls,www.demo.thuto.co.ls'))" > allowed_hosts.txt

echo.
echo ✅ Secrets generated successfully!
echo.
echo 📋 Your base64 encoded secrets:
echo.

echo SECRET_KEY:
type secret_key.txt
echo.

echo DEBUG:
type debug.txt  
echo.

echo ALLOWED_HOSTS:
type allowed_hosts.txt
echo.

echo 📝 These values will be automatically updated in k8s/secrets.yaml
echo.

REM Read the generated values
set /p SECRET_KEY_B64=<secret_key.txt
set /p DEBUG_B64=<debug.txt
set /p ALLOWED_HOSTS_B64=<allowed_hosts.txt

REM Create the updated secrets.yaml content
(
echo apiVersion: v1
echo kind: Secret
echo metadata:
echo   name: thuto-secrets
echo   namespace: thuto
echo type: Opaque
echo data:
echo   # Base64 encoded values - automatically generated for demo.thuto.co.ls
echo   SECRET_KEY: %SECRET_KEY_B64%
echo   DEBUG: %DEBUG_B64%
echo   ALLOWED_HOSTS: %ALLOWED_HOSTS_B64%
) > k8s\secrets.yaml

echo ✅ Updated k8s/secrets.yaml with your domain configuration!
echo.

REM Clean up temporary files
del secret_key.txt debug.txt allowed_hosts.txt

echo 🎯 Next steps:
echo 1. Review the updated k8s/secrets.yaml file
echo 2. Update your domain DNS to point to your cluster IP
echo 3. Push your changes to GitHub to deploy
echo.

set /p view=Do you want to view the updated secrets.yaml file? (y/n): 
if /i "%view%"=="y" (
    notepad k8s\secrets.yaml
)

echo.
echo 🚀 Your secrets are ready for demo.thuto.co.ls!
pause
