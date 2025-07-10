#!/bin/bash

# Setup script for Thuto Django Application
# This script helps you set up the project for the first time

echo "🎓 Welcome to Thuto Django Application Setup"
echo "==========================================="

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "📋 Checking prerequisites..."

if ! command_exists python; then
    echo "❌ Python is not installed. Please install Python 3.11+"
    exit 1
fi

if ! command_exists git; then
    echo "❌ Git is not installed. Please install Git"
    exit 1
fi

echo "✅ Prerequisites check passed"

# Set up virtual environment
echo "🔧 Setting up virtual environment..."
python -m venv venv

# Activate virtual environment
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    source venv/Scripts/activate
else
    source venv/bin/activate
fi

echo "✅ Virtual environment activated"

# Install dependencies
echo "📦 Installing dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

echo "✅ Dependencies installed"

# Run Django setup
echo "🚀 Setting up Django..."
python manage.py migrate
python manage.py collectstatic --noinput

echo "✅ Django setup complete"

# Create superuser (optional)
read -p "📝 Do you want to create a Django superuser? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    python manage.py createsuperuser
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "To start the development server:"
echo "1. Activate virtual environment: source venv/bin/activate (Linux/Mac) or venv\\Scripts\\activate (Windows)"
echo "2. Run server: python manage.py runserver"
echo "3. Visit: http://localhost:8000"
echo ""
echo "For Docker development:"
echo "docker-compose up --build"
echo ""
echo "Happy coding! 🚀"
