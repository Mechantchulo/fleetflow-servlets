# Expression Language (EL) in ATMS

EL in JSP lets you print values using `${...}` instead of Java code blocks.

## Why EL Is Used

- cleaner JSP pages
- easier to read than scriptlets for simple output
- directly accesses request/session attributes

## Common EL Usage in This Project

- session/user display:
  - `${username}`
- totals and metrics:
  - `${totalRequests}`, `${approvedRequests}`, `${pendingRequests}`
- form or filter values:
  - `${reportStartDate}`, `${reportEndDate}`
- object method/property style access in JSP loops:
  - `${req.getDestination()}`

## Scope Resolution

EL resolves values from:

- page scope
- request scope
- session scope
- application scope

In ATMS, most dashboard data is put in **request scope** by servlets and then rendered with EL.

## EL vs Scriptlets in This Codebase

- EL is used for simple value rendering
- scriptlets (`<% ... %>`) are still present for loops/conditional logic in some JSP files

Both are currently mixed; EL is preferred for maintainability when possible.

