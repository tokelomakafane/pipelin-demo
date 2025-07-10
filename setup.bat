@echo off
echo Creating virtual environment...
python -m venv venv

echo Activating virtual environment...
call venv\Scripts\activate.bat

echo Installing Django and dependencies...
pip install -r requirements.txt

echo Creating Django project...
django-admin startproject thuto_project .

echo Creating Django app...
python manage.py startapp thuto_app

echo Running initial migrations...
python manage.py migrate

echo Setup complete!
echo To activate the virtual environment, run: venv\Scripts\activate.bat
echo To run the server, run: python manage.py runserver
