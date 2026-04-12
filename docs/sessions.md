# Sessions in ATMS

ATMS uses `HttpSession` for authentication state and role-based access control.

## Core Session Attributes

Set at login (mainly in `LoginServlet`):

- `username`
- `fullName`
- `userRole`
- `managerUsername` (for manager role helpers)

Session timeout:

- configured to 30 minutes in:
  - `src/main/webapp/WEB-INF/web.xml` (`<session-timeout>30</session-timeout>`)

## Where Sessions Are Implemented

## Login / Logout

- `com.auth.LoginServlet`
  - creates session on successful authentication
  - sets role and user identity attributes
- `com.auth.LogoutServlet`
  - invalidates session and redirects to login
- role-specific legacy login/logout also exist:
  - `ManagerLoginServlet`, `ManagerLogoutServlet`, `DeanLogoutServlet`

## Role Guards in Servlets

Each module checks session role before processing:

- staff pages: check `userRole == STAFF`
- timetabling pages: check `userRole == TIMETABLING_STAFF`
- manager pages: check `userRole == TRANSPORT_MANAGER`
- driver pages: check `userRole == DRIVER`
- dean pages: check `userRole == DEAN`

## Utility Helpers

- `ManagerSessionUtil`
- `DeanSessionUtil`

These centralize role-check and login redirect behavior for some controller paths.

## Why Sessions Matter Here

- prevent unauthorized dashboard access
- keep user identity available for DB filtering (e.g., “my requests”, “my trips”)
- allow safe role-based redirects after login

