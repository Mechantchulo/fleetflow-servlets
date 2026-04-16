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

## 12) Validation changes log

The following files were updated to enforce:
- no numbers/symbols in username fields
- letters/spaces-only in name/department fields
- numeric values not going below `0` where applicable

### Backend (server-side)

- `src/main/java/com/transportmanager/util/ValidationUtil.java`
  - Added shared validation helpers for text and non-negative numbers.
- `src/main/java/com/auth/StaffSignupServlet.java`
  - Added full name, department, and username format checks.
- `src/main/java/com/auth/AuthDAO.java`
  - Added DAO-level fallback checks for staff registration validation.
- `src/main/java/com/transportmanager/controller/ManagerDriversServlet.java`
  - Added full name and username format checks for driver creation.
- `src/main/java/com/transportmanager/dao/DriverDAO.java`
  - Added DAO-level fallback checks for driver creation validation.
- `src/main/java/com/staff/servletss/StaffDashboardServlet.java`
  - Enforced non-negative passengers and department text validation.
- `src/main/java/com/staff/dao/StaffTripDAO.java`
  - Updated passenger storage guard from minimum `1` to minimum `0`.
- `src/main/java/com/timetabling/controller/TimetablingDashboardServlet.java`
  - Added non-negative passenger/budget validation and department format checks.
- `src/main/java/com/timetabling/controller/ScheduleRequestServlet.java`
  - Added non-negative budget validation and department format checks.
- `src/main/java/com/driver/TripLogs/TripLogServlet.java`
  - Added non-negative mileage/fuel validation.
- `src/main/java/com/driver/FuelLogs/FuelLogsServlet.java`
  - Added non-negative mileage/fuel validation.

### Frontend forms (client-side constraints)

- `src/main/webapp/WEB-INF/auth/staffSignup.jsp`
  - Added `pattern` constraints for full name, department, and username.
- `src/main/webapp/WEB-INF/manager/manageDrivers.jsp`
  - Added `pattern` constraints for full name and username.
- `src/main/webapp/WEB-INF/staff/staffDashboard.jsp`
  - Added department `pattern` and passengers `min="0"`.
- `src/main/webapp/WEB-INF/timetabling/timetablingDashboard.jsp`
  - Added department `pattern` and non-negative numeric limits.
- `src/main/webapp/WEB-INF/timetabling/scheduleRequest.jsp`
  - Added department `pattern` and non-negative budget limit.
