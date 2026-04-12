# ATMS System Overview

ATMS (Academic Trip Management System) is a Java Servlet + JSP web application used to manage academic and club transport workflows in one place.

## Main Goal

Replace manual trip processing with a role-based digital workflow for:

- staff trip requests
- timetabling scheduling and publishing
- transport manager approvals and allocations
- driver trip execution and trip logging
- dean oversight for club-related trips
- PDF reporting for each actor

## Technology Stack

- Java 17
- Jakarta Servlet/JSP (Tomcat 10+)
- PostgreSQL
- Maven (`war` packaging)
- PDFBox (PDF exports)
- HTML/CSS/JS frontend

## Architecture Style

- MVC-style separation:
  - `controller`/`servlet` classes handle HTTP logic
  - `dao` classes handle database access
  - `model` classes (JavaBeans/POJOs) represent data
  - JSP under `WEB-INF` renders protected views

## Key Modules

- `auth`: login, logout, signup
- `staff`: request creation, request history, trip history, request PDF upload/download
- `timetabling`: request scheduling into official timetable entries and submission to manager
- `transportmanager`: queue review, decision, bus/driver allocation, overrides, reports
- `driver`: assigned trips, trip logs (start/end/report notes), personal reports
- `reports`: actor-specific PDF export endpoints

## Data Highlights

Core tables:

- `users`
- `trip_request`
- `timetable_entry`
- `trip_assignment`
- `vehicle`
- `driver_trip_log`

