from django.shortcuts import render
from django.http import HttpResponse

def welcome(request):
    """View that displays welcome message to Thuto"""
    return render(request, 'thuto_app/welcome.html')
