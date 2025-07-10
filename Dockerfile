# Use nginx alpine image for serving static HTML
FROM nginx:alpine

# Copy HTML file to nginx default directory
COPY index.html /usr/share/nginx/html/

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 8080 (nginx will run on this port)
EXPOSE 8080

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
