.PHONY: docker-build docker-run docker-stop logs psql clean

IMAGE := portaria-db
CONTAINER := portaria-db
ENVIRONMENT ?= development
PORT ?= 5432

docker-build:
	docker build -t $(IMAGE) .

docker-run: docker-build
	@SELECTED_ENV=""; \
	if [ -f ".env.$(ENVIRONMENT)" ]; then SELECTED_ENV=".env.$(ENVIRONMENT)"; \
	elif [ -f ".env.local" ]; then SELECTED_ENV=".env.local"; \
	elif [ -f ".env" ]; then SELECTED_ENV=".env"; \
	else echo "No .env file found for $(ENVIRONMENT)"; exit 1; fi; \
	echo "Using env file: $$SELECTED_ENV"; \
	(docker stop $(CONTAINER) >/dev/null 2>&1 || true); \
	(docker rm $(CONTAINER) >/dev/null 2>&1 || true); \
	docker run -d --name $(CONTAINER) --env-file $$SELECTED_ENV -p $(PORT):5432 $(IMAGE)

docker-stop:
	docker stop $(CONTAINER) >/dev/null 2>&1 || true

logs:
	docker logs -f $(CONTAINER)

psql:
	docker exec -it $(CONTAINER) sh -c 'psql -U "$$POSTGRES_USER" -d "$$POSTGRES_DB"'

clean: docker-stop
	docker rm $(CONTAINER) >/dev/null 2>&1 || true
	rm -rf data/
