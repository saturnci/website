#!/bin/bash

set -e

# Create .saturnci directory
mkdir -p .saturnci

# Create Dockerfile
cat <<EOF > .saturnci/Dockerfile
FROM ruby:3.3.5

WORKDIR /code

COPY Gemfile Gemfile.lock /code/
RUN bundle install

COPY . /code

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
EOF

# Create docker-compose.yml
cat <<EOF > .saturnci/docker-compose.yml
version: "3.8"

services:
  saturn_test_app:
    build:
      context: ../
      dockerfile: .saturnci/Dockerfile
    image: \${SATURN_TEST_APP_IMAGE_URL}
    volumes:
      - ../:/code
    depends_on:
      - postgres
      - chrome
    environment:
      DOCKER_ENV: "true"
      DATABASE_USERNAME: saturn
      DATABASE_PASSWORD: ""
      DATABASE_HOST: postgres
      DATABASE_PORT: 5432
      RAILS_ENV: test

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

  chrome:
    image: seleniarm/standalone-chromium
    hostname: chrome
    shm_size: 2g
    ports:
      - "4444:4444"

volumes:
  postgresql:
EOF

# Create database.yml
cat <<EOF > .saturnci/database.yml
test:
  database: saturn_test
  adapter: postgresql
  encoding: unicode
  username: <%= ENV.fetch("DATABASE_USERNAME") %>
  host: <%= ENV.fetch("DATABASE_HOST") %>
  port: <%= ENV.fetch("DATABASE_PORT") %>
EOF

# Create pre.sh
cat <<EOF > .saturnci/pre.sh
#!/bin/bash
rails db:create && \\
  rails db:schema:load && \\
  rails assets:precompile
EOF
