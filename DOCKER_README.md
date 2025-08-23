# Hotel Management System - Docker Setup

This directory contains the Docker configuration for the Hotel Management System.

## Prerequisites

- Docker Desktop installed and running
- WSL 2 backend configured (for Windows)

## Quick Start

1. Build and start the services:
   ```bash
   docker-compose up --build
   ```

2. Access the application:
   - Phoenix Web App: http://localhost:4000
   - PostgreSQL: localhost:5432 (User: postgres, Password: postgres)
   - SurrealDB: localhost:8000

## Services

- `app`: The Elixir/Phoenix application
- `db`: PostgreSQL database for analytics
- `surrealdb`: SurrealDB for primary data storage

## Development

For development, you might want to run commands inside the container:

```bash
# Shell into the app container
docker-compose exec app sh

# Run Elixir commands
docker-compose exec app mix deps.get
docker-compose exec app mix ecto.create
docker-compose exec app mix ecto.migrate
```