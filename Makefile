# Force loading .env into Makefile and pass to docker compose
include .env
export $(shell sed 's/=.*//' .env)

DC = docker compose

.DEFAULT_GOAL := help

up: ## Build and start containers
	$(DC) --env-file .env up -d --build

down: ## Stop containers but keep volumes
	$(DC) --env-file .env down

nuke: ## Full reset (delete volumes too)
	$(DC) --env-file .env down -v --remove-orphans

logs: ## Follow logs
	$(DC) --env-file .env logs -f --tail=100

scale: ## Scale workers (use: make scale N=5)
	$(DC) --env-file .env up -d --scale n8n-worker=$(N)

workflows: ## List imported workflows
	$(DC) --env-file .env exec n8n-main n8n list:workflow

trigger: ## Trigger a workflow by ID (WF_ID must be provided)
	@if [ -z "$(WF_ID)" ]; then echo "WF_ID missing"; exit 1; fi
	N8N_WEBHOOK_URL="http://localhost:$(N8N_PORT)/webhook/$(WF_ID)/welcome" \
	N8N_BASIC_AUTH_USER=$(N8N_BASIC_AUTH_USER) \
	N8N_BASIC_AUTH_PASSWORD=$(N8N_BASIC_AUTH_PASSWORD) \
	python3 tools/trigger.py

help: ## Show all commands
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) \
	| awk 'BEGIN{FS=":.*?## "};{printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'
