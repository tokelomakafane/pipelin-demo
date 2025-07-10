from django.test import TestCase, Client
from django.urls import reverse

class WelcomeViewTest(TestCase):
    def setUp(self):
        self.client = Client()
    
    def test_welcome_page_status_code(self):
        """Test that welcome page returns 200 status code"""
        response = self.client.get(reverse('welcome'))
        self.assertEqual(response.status_code, 200)
    
    def test_welcome_page_content(self):
        """Test that welcome page contains expected content"""
        response = self.client.get(reverse('welcome'))
        self.assertContains(response, 'Welcome to Thuto')
        self.assertContains(response, 'learning')
    
    def test_welcome_page_template(self):
        """Test that welcome page uses correct template"""
        response = self.client.get(reverse('welcome'))
        self.assertTemplateUsed(response, 'thuto_app/welcome.html')
