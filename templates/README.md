# SaturnCI Templates

This directory contains templates for quickly setting up SaturnCI in your projects.

## Rails Template

The Rails template adds SaturnCI configuration to any existing Rails application.

### Usage

Run this command from your Rails application directory:

```bash
rails app:template LOCATION=https://raw.githubusercontent.com/saturnci/website/main/templates/rails_template.rb
```

### What it adds

The template will add the following to your Rails application:

- `.saturnci/` directory with all necessary configuration files:
  - `Dockerfile` - Defines the test environment container
  - `docker-compose.yml` - Orchestrates test services (app, PostgreSQL, Chrome)
  - `database.yml` - Test database configuration
  - Convenience scripts (`up.sh`, `down.sh`, `run.sh`)
- RSpec configuration (if not already present)
- `.rspec` file with recommended settings

### After applying the template

1. Run `bundle install` to install any new gems
2. Commit the changes to your repository
3. Add your repository to SaturnCI at https://app.saturnci.com
4. Push your code to trigger your first test run!

### Local testing

You can test your SaturnCI configuration locally:

```bash
cd .saturnci
./up.sh                           # Start services
./run.sh bundle exec rspec        # Run tests
./down.sh                         # Stop services
```