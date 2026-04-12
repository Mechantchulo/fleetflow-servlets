# ATMS System Flow

## End-to-End Workflow

1. Staff logs in and submits a trip request.
2. Request includes destination, department, preferred date, passenger count, budget, and optional PDF document.
3. Timetabling staff sees pending `REQUESTED` requests.
4. Timetabling selects a request, opens schedule page, sets final date/time and budget.
5. System creates `timetable_entry` and marks request as scheduled/submitted through flow states.
6. Timetabling submits published timetable entries to manager.
7. Transport manager reviews pending queue and confirms/rejects as needed.
8. Transport manager allocates bus and driver.
9. Driver sees assigned trips on dashboard.
10. Driver logs trip start/end times and incident/other operational notes.
11. All actors can export their role-specific PDF reports.

## Typical Status Progression (Academic)

- `REQUESTED` -> `SCHEDULED` -> `SUBMITTED` -> manager handling (`APPROVED/CONFIRMED/REJECTED`) -> assignment stages

## Club/Dean Note

- Club-related requests can be filtered/handled in dean workflow for oversight and approval paths.

