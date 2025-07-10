@echo off
echo.
echo ========================================
echo   🎓 Thuto Django Application Setup
echo ========================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python is not installed or not in PATH
    echo Please install Python 3.11+ from https://python.org
    pause
    exit /b 1
)

echo ✅ Python is installed
echo.

REM Check if Git is installed
git --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Git is not installed or not in PATH
    echo Please install Git from https://git-scm.com
    pause
    exit /b 1
)

echo ✅ Git is installed
echo.

REM Create virtual environment if it doesn't exist
if not exist "venv" (
    echo 🔧 Creating virtual environment...
    python -m venv venv
    if errorlevel 1 (
        echo ❌ Failed to create virtual environment
        pause
        exit /b 1
    )
    echo ✅ Virtual environment created
) else (
    echo ✅ Virtual environment already exists
)

echo.
echo 📦 Activating virtual environment and installing dependencies...
call venv\Scripts\activate.bat

pip install --upgrade pip
pip install -r requirements.txt

if errorlevel 1 (
    echo ❌ Failed to install dependencies
    pause
    exit /b 1
)

echo ✅ Dependencies installed
echo.

echo 🗄️ Setting up Django database...
python manage.py migrate

if errorlevel 1 (
    echo ❌ Failed to run migrations
    pause
    exit /b 1
)

echo ✅ Database setup complete
echo.

echo 🧪 Running tests...
python manage.py test

if errorlevel 1 (
    echo ❌ Tests failed
    pause
    exit /b 1
)

echo ✅ All tests passed
echo.

echo 📊 Collecting static files...
python manage.py collectstatic --noinput

echo.
echo ========================================
echo           🎉 Setup Complete!
echo ========================================
echo.
echo Your Thuto Django application is ready!
echo.
echo To start the development server:
echo   1. Open a new terminal
echo   2. Navigate to this directory
echo   3. Run: venv\Scripts\activate
echo   4. Run: python manage.py runserver
echo   5. Visit: http://localhost:8000
echo.
echo For production deployment:
echo   1. See DEPLOYMENT_GUIDE.md for complete instructions
echo   2. Use encode-kubeconfig.bat to help with GitHub secrets setup
echo   3. Read UNDERSTANDING_PIPELINE.md to understand the process
echo.

set /p answer=Do you want to start the development server now? (y/n): 
if /i "%answer%"=="y" (
    echo.
    echo 🚀 Starting Django development server...
    echo Visit http://localhost:8000 to see your application
    echo Press Ctrl+C to stop the server
    echo.
    python manage.py runserver
)

echo.
echo Thank you for using Thuto! 🎓
pause
