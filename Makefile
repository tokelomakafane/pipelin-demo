.PHONY: help install dev-install test run docker-build docker-run deploy clean

help: ## Show this help message
	@echo "Thuto Django Application Commands"
	@echo "=================================="
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*##/ {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## Install production dependencies
	pip install -r requirements.txt

dev-install: ## Install development dependencies and setup
	python -m venv venv
	./venv/Scripts/activate && pip install -r requirements.txt
	./venv/Scripts/activate && python manage.py migrate
	./venv/Scripts/activate && python manage.py collectstatic --noinput

test: ## Run Django tests
	python manage.py test
	python manage.py check

run: ## Run Django development server
	python manage.py runserver

migrate: ## Run Django migrations
	python manage.py migrate

collect-static: ## Collect static files
	python manage.py collectstatic --noinput

docker-build: ## Build Docker image
	docker build -t thuto-app .

docker-run: ## Run Docker container
	docker run -p 8000:8000 thuto-app

docker-dev: ## Run with docker-compose for development
	docker-compose up --build

k8s-deploy: ## Deploy to Kubernetes
	kubectl apply -f k8s/

k8s-delete: ## Delete Kubernetes deployment
	kubectl delete -f k8s/

k8s-status: ## Check Kubernetes deployment status
	kubectl get pods -n thuto
	kubectl get services -n thuto
	kubectl get ingress -n thuto

clean: ## Clean up generated files
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -delete
	rm -rf staticfiles/
