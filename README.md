FleetFlow Servlets - Runtime Setup

Recommended approach for this repository:
- Reuse the shared PostgreSQL container used by your other application.
- Keep an optional local PostgreSQL service in docker-compose for isolated testing.

What was added:
- docker-compose.yml: Optional local DB only (profile: localdb).
- .env.example: Shared DB and local DB environment values.

How to use shared DB (default and recommended)
1) Ensure your shared DB container is running (for example fleetflow-db on host port 5434).
2) Copy .env.example to .env and keep:
   DB_HOST=localhost
   DB_PORT=5434
   DB_NAME=fleetflow
   DB_USER=postgres
   DB_PASSWORD=...
3) Use these values in your servlet DAO connection utility.

How to run an isolated local DB for this repo
1) Copy .env.example to .env and set your preferred values.
2) Start local DB profile:
   docker compose --profile localdb up -d
3) This repo-local DB defaults to host port 5435 to avoid conflicts.

Why this is the best fit for now
- Avoids fighting over one DB container name/port between multiple projects.
- Supports team reproducibility.
- Keeps this servlet repo independent while still compatible with shared infrastructure.
