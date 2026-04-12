# Project Structure

## Root

- `pom.xml`  
  Maven config, dependencies (Jakarta API, PostgreSQL JDBC, PDFBox), Java 17 build settings.

- `docker-compose.yml`  
  Optional local PostgreSQL service under `localdb` profile.

- `.env` / `.env.example`  
  DB connection values used for local runtime setup.

- `sql/`  
  Database schema, migrations, and seed scripts.

- `README.md`  
  Runtime notes and setup guidance.

## `src/main/java`

## `com.auth`

- authentication and account flows:
  - login/logout/signup
  - credential verification (`AuthDAO`)
  - authenticated user bean (`AuthUser`)

## `com.staff`

- `dao`  
  SQL access for staff requests/history.
- `model`  
  staff beans (`Request`, `Trip`).
- `servletss`  
  staff dashboards, my requests, trip history, document download.

## `com.timetabling`

- `controller`  
  timetabling dashboard, schedule page, PDF export.
- `dao`  
  timetable CRUD and submission logic.
- `model`  
  `TimetableEntry` bean.

## `com.transportmanager`

- `controller`  
  manager/dean dashboards and allocation flow servlets.
- `dao`  
  bus, driver, trip data access.
- `model`  
  core domain beans (`Trip`, `Bus`, `Driver`, etc.).
- `service`  
  orchestration helpers for queue/allocation logic.
- `util`  
  DB util, validation, session helpers.

## `com.driver`

- `driverdashboard`  
  driver dashboard, report servlet, trip/log beans.
- `TripLogs`, `FuelLogs`  
  additional driver logging classes/servlets (legacy/simple flows).

## `com.reports`

- shared actor-based PDF export servlet (`ActorReportPdfServlet`).

## `src/main/webapp`

- `index.jsp`  
  landing and login page.
- `WEB-INF/`  
  protected JSP views per role:
  - `auth/`
  - `staff/`
  - `timetabling/`
  - `manager/`
  - `driver/`
  - `dean/`
- `WEB-INF/web.xml`  
  web config (session timeout etc.).
- `WEB-INF/beans.xml`  
  CDI discovery descriptor.
- `css/`, `js/`  
  frontend styling and behavior files.

