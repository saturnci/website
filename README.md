## What is SaturnCI?

SaturnCI is a continuous integration platform for Ruby on Rails applications.

[screenshot]

## Why another CI service?

What distinguishes SaturnCI from other CI services like CircleCI and GitHub Actions is the user-friendliness of its interface.

Because SaturnCI is tailored specifically to Rails apps instead of being technology-agnostic, SaturnCI can make assumptions about how your build process works and what you want to see.

## How does SaturnCI work?

When you do a Git push, SaturnCI will automatically start a **build**. For performance reasons, SaturnCI runs chunks of your test suite in parallel. Each build is associated with one or more **runners**, each of which will perform a **run** of part of your test suite.

For example, if your test suite has 80 tests and your parallelization is set to 2, your build will get 2 runners, each of which run 40 tests. If your test suite has 80 tests and your parallelization is set to 8, your build will get 8 runners, each of which runs 10 tests.

## How do I get started?

### Requirements

SaturnCI only works for Ruby on Rails applications, and currently only for the RSpec framework.

### Create a SaturnCI account

1. Visit [https://app.saturnci.com](https://app.saturnci.com)
2. Click "Sign up with GitHub"
3. Grant permissions to GitHub

[screenshot]

### Install the SaturnCI GitHub app

1. Visit [https://github.com/apps/saturnci](https://github.com/apps/saturnci)
2. Click "Configure"
3. Grant permissions to SaturnCI for whichever repositories you wish

### Add the SaturnCI configuration files to your repository

```Dockerfile
# .saturnci/Dockerfile

FROM ruby:3.3.5

WORKDIR /code

COPY Gemfile Gemfile.lock /code/
RUN bundle install

COPY . /code

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
```

```yaml
# .saturnci/docker-compose.yml

version: "3.8"

services:
  saturn_test_app:
    build:
      context: ../
      dockerfile: .saturnci/Dockerfile
    image: ${SATURN_TEST_APP_IMAGE_URL}
    volumes:
      - ../:/code
    depends_on:
      - postgres
      - redis
      - chrome
    environment:
      DOCKER_ENV: "true"
      DATABASE_USERNAME: saturn
      DATABASE_PASSWORD: ""
      DATABASE_HOST: postgres
      DATABASE_PORT: 5432
      RAILS_ENV: test
      REDIS_URL: redis://redis:6379/0
      SATURNCI_API_USERNAME: myuser
      SATURNCI_API_PASSWORD: mypassword

  postgres:
    image: postgres:13.1-alpine
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

  redis:
    image: redis:4.0.14-alpine
    volumes:
      - redis:/data:delegated
    ports:
      - "127.0.0.1:6379:6379"
    restart: on-failure
    logging:
      driver: none

  chrome:
    image: seleniarm/standalone-chromium
    hostname: chrome
    shm_size: 2g
    ports:
      - "4444:4444"

volumes:
  postgresql:
  redis:
```

```bash
.saturnci/pre.sh

#!/bin/bash
rails db:create
rails db:schema:load
rails assets:precompile
```
