# JavaBeans in ATMS

## What Is a JavaBean?

In this project context, a JavaBean is a simple Java class with:

- private fields
- public no-arg constructor
- public getters/setters

Used to carry data between DAO -> Servlet -> JSP cleanly.

## Why They Help

- keep code organized and readable
- reduce raw `ResultSet` handling inside JSP
- support MVC separation
- make session/request attributes easier to pass and render

## JavaBeans Used in This Project

## Auth Module

- `AuthUser`
  - represents authenticated user details (id, username, role, etc.)

## Transport Manager Module

- `com.transportmanager.model.Trip`
- `Bus`
- `Driver`
- `TripAssignment`
- `TransportManager`
- `StaffMember`
- `TimetablingStaff`
- `Dean`

These support queueing, allocations, role entities, and report data.

## Staff Module

- `com.staff.model.Request`
- `com.staff.model.Trip`

Used for staff dashboard/history tables.

## Timetabling Module

- `com.timetabling.model.TimetableEntry`

Represents published/submitted timetable records.

## Driver Module

- `com.driver.driverdashboard.Trip`
- `DriverTripLog` (new)
- legacy/simple models in:
  - `com.driver.TripLogs.TripLog`
  - `com.driver.FuelLogs.FuelLogs`

## Typical Bean Flow in ATMS

1. DAO reads DB row.
2. DAO maps row -> Bean object.
3. Servlet stores bean/list as request attribute.
4. JSP renders bean values in tables/cards/forms.

