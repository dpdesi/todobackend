

# Project variables
PROJECT_NAME ?= todobackend
ORG_NAME ?= dpdesi
REPO_NAME ?= todobackend

# Filenames
DEV_COMPOSE_FILE := docker/dev/docker-compose.yml
REL_COMPOSE_FILE := docker/release/docker-compose.yml

# Docker Compose Project Names
REL_PROJECT := $(PROJECT_NAME)$(BUILD_ID)
DEV_PROJECT := $(REL_PROJECT)dev

.PHONY: test build release clean



# Project variables
PROJECT_NAME ?= todobackend
ORG_NAME ?= dpdesi
REPO_NAME ?= todobackend

# Filenames
DEV_COMPOSE_FILE := docker/dev/docker-compose.yml
REL_COMPOSE_FILE := docker/release/docker-compose.yml

# Docker Compose Project Names
REL_PROJECT := $(PROJECT_NAME)$(BUILD_ID)
DEV_PROJECT := $(REL_PROJECT)dev

.PHONY: test build release clean

test:
	${INFO} "Pulling latest images..."
	@ docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) pull
	${INFO} "Building images..."
	@ docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) build --pull test
	@ docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) build cache
	${INFO} "Ensuring database is ready..."
	@ docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) run --rm agent
	${INFO} "Running tests..."
	@ docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) up test
	${INFO} "Testing complete"

build:
	${INFO} "Creating builder image..."
	@ docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) build builder
	${INFO} "Building application artifacts..."
	@ docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) up builder

release:
	${INFO} "Pulling latest images..."
	@ docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) pull test
	${INFO} "Building images..."
	@ docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) build app
	@ docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) build webroot
	@ docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) build --pull nginx
	${INFO} "Ensuring database is ready..."
	@ docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) run --rm agent
	${INFO} "Collecting static files..."
	@ docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) run --rm app manage.py collectstatic --noinput
	${INFO} "Running database migrations..."
	@ docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) run --rm app manage.py migrate --noinput
	${INFO} "Running acceptance tests..."
	@ docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) up test
	${INFO} "Acceptance testing complete"

clean:
	${INFO} "Destroying development environment..."
	@ docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) kill
	@ docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) rm -f -v
	${INFO} "Destroying release environment..."
	@ docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) kill
	@ docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) rm -f -v
	${INFO} "Removing dangling images..."
	@ docker images -q -f dangling=true -f label=application=$(REPO_NAME) | xargs -I ARGS docker rmi -f ARGS
	${INFO} "Clean complete"

# Cosmetics 
YELLOW := "\e[1;33m"
NC := "\e[0m"

# Shell Functions
INFO := @bash -c '\
	printf $(YELLOW); \
	echo "=> $$1"; \
	printf $(NC)' VALUE



