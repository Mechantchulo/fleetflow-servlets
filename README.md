# ATMS (Fleetflow Servlets)

Academic Trip Management System (ATMS) built with Java Servlets + JSP, PostgreSQL, and Tomcat.

This guide is for team members cloning the repository and running it locally.

## 1) Prerequisites

- Java 17
- Maven 3.9+
- Apache Tomcat 10.x
- Docker + Docker Compose (recommended for local PostgreSQL)
- PostgreSQL client (`psql`) optional but useful for checks

## 2) Clone and enter project

```bash
git clone <your-repo-url>
cd fleetflow-servlets
```

## 3) Configure environment

Copy the sample env file:

```bash
cp .env.example .env
```

Set DB values in `.env` (example):

```env
DB_HOST=localhost
DB_PORT=5435
DB_NAME=academic_trip_db
DB_USER=erick
DB_PASSWORD=change_me
LOCAL_DB_PORT=5435
```

## 4) Start local database (recommended)

```bash
docker compose --profile localdb up -d
```

## 5) Apply schema + migrations + seeds

Important: use input redirection (`<`) so files are read from your host machine.

```bash
docker compose --profile localdb exec -T db psql -U "$DB_USER" -d "$DB_NAME" < sql/schema.sql
docker compose --profile localdb exec -T db psql -U "$DB_USER" -d "$DB_NAME" < sql/auth_migration.sql
docker compose --profile localdb exec -T db psql -U "$DB_USER" -d "$DB_NAME" < sql/timetable_submission_migration.sql
docker compose --profile localdb exec -T db psql -U "$DB_USER" -d "$DB_NAME" < sql/staff_request_documents_migration.sql
docker compose --profile localdb exec -T db psql -U "$DB_USER" -d "$DB_NAME" < sql/user_department_migration.sql
docker compose --profile localdb exec -T db psql -U "$DB_USER" -d "$DB_NAME" < sql/driver_trip_log_migration.sql
docker compose --profile localdb exec -T db psql -U "$DB_USER" -d "$DB_NAME" < sql/seed_preassigned_users.sql
docker compose --profile localdb exec -T db psql -U "$DB_USER" -d "$DB_NAME" < sql/seed_vehicles.sql
docker compose --profile localdb exec -T db psql -U "$DB_USER" -d "$DB_NAME" < sql/seed_drivers.sql
```

If your shell does not export `.env` values automatically, replace `$DB_USER` and `$DB_NAME` with explicit values.

## 6) Build WAR

```bash
mvn clean package -DskipTests
```

WAR output:

- `target/FleetflowServlets-1.0-SNAPSHOT.war`

## 7) Deploy to Tomcat

Copy WAR to Tomcat `webapps`:

```bash
cp target/FleetflowServlets-1.0-SNAPSHOT.war <TOMCAT_HOME>/webapps/
```

Start Tomcat with DB JVM properties (required by DB utility):

```bash
CATALINA_OPTS="-DDB_HOST=localhost -DDB_PORT=5435 -DDB_NAME=academic_trip_db -DDB_USER=erick -DDB_PASSWORD=change_me -DAUTH_DEBUG=true" <TOMCAT_HOME>/bin/startup.sh
```

To restart:

```bash
<TOMCAT_HOME>/bin/shutdown.sh
CATALINA_OPTS="-DDB_HOST=localhost -DDB_PORT=5435 -DDB_NAME=academic_trip_db -DDB_USER=erick -DDB_PASSWORD=change_me -DAUTH_DEBUG=true" <TOMCAT_HOME>/bin/startup.sh
```

## 8) Access application

Open:

- `http://localhost:8080/FleetflowServlets-1.0-SNAPSHOT/`

## 9) Role testing

Preassigned users are seeded via:

- `sql/seed_preassigned_users.sql`

Driver test accounts are seeded via:

- `sql/seed_drivers.sql`

Check those files for current usernames/credentials in your environment.

## 10) Useful troubleshooting

- `No suitable driver found for jdbc:postgresql://...`
  - PostgreSQL JDBC dependency not loaded in deployed WAR or old WAR still active. Rebuild and redeploy.

- `Address already in use` on `8080`/`8005`
  - Another Tomcat instance is already running. Stop it first.

- SQL file “not found” when using `-f` inside container
  - Use host redirection: `... psql ... < sql/file.sql`

- Check Tomcat logs
  - `<TOMCAT_HOME>/logs/catalina.out`

## 11) Team workflow suggestion

- Keep SQL scripts idempotent (`IF NOT EXISTS`) when adding migrations.
- Document new endpoints/flows in `docs/`.
- For shared environments, avoid committing real secrets in `.env`.
