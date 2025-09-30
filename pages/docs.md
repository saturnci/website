---
page_title: Docs
nav: docs
---

# Documentation

## Docker Compose Configuration

```yaml
version: "3.8"

services:
  saturn_test_app:
    # This hostname is what will go in the Capybara host config.
    hostname: saturn_test_app

    image: ${SATURN_TEST_APP_IMAGE_URL}:latest
    volumes:
      - ../:/code
      - ./database.yml:/code/config/database.yml:ro
    depends_on:
      - postgres
      - chrome

    # .saturnci/.env is where SaturnCI will put the environment variables
    # that you set in your repository's Secrets section in Settings.
    #
    # Optionally, you can add a local .saturnci.env file to provide environment
    # variables when you run your SaturnCI setup locally.
    env_file:
      - .env

    environment:
      DOCKER_ENV: "true"
      DATABASE_USERNAME: saturn
      DATABASE_PASSWORD: ""
      DATABASE_HOST: postgres
      DATABASE_PORT: 5432
      RAILS_ENV: test

    healthcheck:
      test: ["CMD", "curl", "--fail", "http://localhost:3000"]
      interval: 10s
      timeout: 5s
      retries: 10

  postgres:
    image: postgres:17.2-alpine
    volumes:
      - postgresql:/var/lib/postgresql/data:delegated
      - ./init.sql:/data/application/init.sql
    ports:
      - "127.0.0.1:5432:5432"
    environment:
      PSQL_HISTFILE: /usr/src/app/log/.psql_history
      POSTGRES_USER: saturn
      POSTGRES_HOST_AUTH_METHOD: trust
    restart: on-failure
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U saturn"]
      interval: 10s
      timeout: 2s
      retries: 10
    logging:
      driver: none

  chrome:
    image: seleniarm/standalone-chromium
    hostname: chrome
    shm_size: 2g
    ports:
      - "4444:4444"
    healthcheck:
      test: ["CMD", "curl", "--fail", "http://localhost:4444/wd/hub/status"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  postgresql:
```