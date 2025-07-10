# Use the official Apache HTTP Server image
FROM httpd:2.4

# Copy the HTML file to the Apache document root
COPY templates/thuto_app/welcome.html /usr/local/apache2/htdocs/index.html

# Expose port 80
EXPOSE 80

# Start Apache in the foreground
CMD ["httpd-foreground"]
