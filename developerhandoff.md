# Transport Manager JSP Developer Handoff

## Purpose
This handoff documents the JSP views required by the Transport Manager module and the exact contracts expected by existing servlets.

Scope:
- JSP implementation only
- No controller/DAO changes required for first pass
- Follow existing request attributes and form parameter names exactly

---

## Where to create JSP files
Create these files under:
- `src/main/webapp/WEB-INF/manager/`

Required JSP files:
1. `managerLogin.jsp`
2. `pendingTripQueue.jsp`
3. `availableBuses.jsp`
4. `availableDrivers.jsp`
5. `allocationSummary.jsp`

Notes:
- Files under `WEB-INF` are not directly browsable by URL (expected).
- They are rendered via servlet forwarding.

---

## Global URL map (already implemented)
- `GET /manager/login` -> login page
- `POST /manager/login` -> login submit
- `GET|POST /manager/logout` -> logout
- `GET /manager/trips/pending` -> pending queue
- `POST /manager/trips/decision` -> approve/reject
- `GET /manager/allocation/buses` -> bus options
- `POST /manager/allocation/bus/assign` -> stage selected bus in session
- `GET /manager/allocation/drivers` -> driver options
- `POST /manager/allocation/driver/assign` -> final assignment (bus+driver write)
- `GET /manager/trips/allocation-summary` -> summary page
- `POST /manager/allocation/override` -> manual override submit

---

## JSP-by-JSP contracts

## 1) managerLogin.jsp
Forwarded by: `ManagerLoginServlet#doGet`

### Request attributes expected
- `error` (String, optional)
- `username` (String, optional; prefill when credentials fail)

### Form required
- Method: `POST`
- Action: `${pageContext.request.contextPath}/manager/login`
- Inputs:
  - `username` (text)
  - `password` (password)
- Submit button

### Optional UX
- If query param `loggedOut=1`, show "Logged out successfully".

---

## 2) pendingTripQueue.jsp
Forwarded by: `PendingTripQueueServlet#doGet`

### Request attributes expected
- `pendingTrips` (List<Trip>)
- `page` (int)
- `size` (int)
- `priority` (String, optional)
- `dateFrom` (LocalDate, optional)
- `dateTo` (LocalDate, optional)

### What to render
- Filter form (GET to `/manager/trips/pending`):
  - `page`, `size`, `priority`, `dateFrom`, `dateTo`
- Table/list of `pendingTrips`:
  - trip id
  - requester name
  - destination
  - departure date
  - passenger count
  - status
  - derived priority (from model)

### Per-trip action forms required
1) Decision form
- Method: `POST`
- Action: `${pageContext.request.contextPath}/manager/trips/decision`
- Inputs:
  - hidden `tripId`
  - `action` (APPROVE or REJECT)
  - `managerNote` (optional text/textarea)

2) Start allocation link
- `GET ${contextPath}/manager/allocation/buses?tripId=<tripId>`

### Optional status messages
Read query params and show friendly message:
- success: `decisionSaved`, `driverAssigned`, `overrideSaved`
- error: `invalidDecisionInput`, `decisionFailed`, `tripNotUpdated`, `invalidTripId`, `tripLookupFailed`, `tripNotFound`, etc.

---

## 3) availableBuses.jsp
Forwarded by: `AvailableBusesServlet#doGet`

### Request attributes expected
- `trip` (Trip)
- `tripId` (long)
- `requiredCapacity` (int)
- `availableBuses` (List<Bus>)

### What to render
- Trip summary at top
- Bus options table/list:
  - bus id
  - plate number
  - mileage
  - status

### Required bus-selection form
- Method: `POST`
- Action: `${pageContext.request.contextPath}/manager/allocation/bus/assign`
- Inputs:
  - hidden `tripId`
  - selected `busId` (radio/select)
  - `override` (boolean, optional; checkbox)
  - `overrideReason` (optional unless override checked)

### Redirect behavior reminder
This submit does not write assignment to DB yet.
It stages bus selection in session and redirects to driver selection.

---

## 4) availableDrivers.jsp
Forwarded by: `AvailableDriversServlet#doGet`

### Request attributes expected
- `trip` (Trip)
- `tripId` (long)
- `selectedBusId` (Long; staged in session)
- `override` (Boolean, optional)
- `overrideReason` (String, optional)
- `availableDrivers` (List<Driver>)

### What to render
- Trip summary
- Selected bus id badge/section (`selectedBusId`)
- Driver options list:
  - driver id
  - full name
  - status

### Required final-assignment form
- Method: `POST`
- Action: `${pageContext.request.contextPath}/manager/allocation/driver/assign`
- Inputs:
  - hidden `tripId`
  - selected `driverId` (radio/select)
  - optional `override` and `overrideReason` fields may be included (server also reuses staged values)

### Redirect behavior reminder
This submit performs final DB write for both bus+driver in one operation.

---

## 5) allocationSummary.jsp
Forwarded by: `AllocationSummaryServlet#doGet`

### Request attributes expected
- `tripId` (long)
- `summary` (Map<String, Object>)

### Common map keys currently provided
- `tripId`
- `tripStatus`
- `destination`
- `departureTime`
- `passengerCount`
- `assignmentId`
- `assignmentStatus`
- `overrideUsed`
- `overrideReason`
- `plateNumber`
- `driverName`
- `managerName`

### What to render
- Summary cards/sections for trip, assignment, vehicle, driver, override
- Link back to pending queue (`/manager/trips/pending`)

---

## Manual override entry point
`ManualOverrideServlet` exists at `POST /manager/allocation/override`.

If needed, add a form on pending queue or summary page:
- Method: POST
- Action: `${contextPath}/manager/allocation/override`
- Inputs:
  - `tripId`
  - `overrideType` (`BUS`, `DRIVER`, `BOTH`)
  - `targetId` (required for BUS/DRIVER)
  - `reason` (required)

---

## UI integration rules
1. Always prefix links/forms with `${pageContext.request.contextPath}`.
2. Keep names of inputs exactly as documented above.
3. Do not change servlet URL patterns without backend coordination.
4. Keep forms simple and explicit; one action per form.

---

## Smoke-test checklist for JSP developer
1. `/manager/login` loads (no 404).
2. Login form submits and redirects to pending queue.
3. Pending queue shows trips and decision forms.
4. Approve/reject redirects back with messages.
5. Bus selection page loads for a trip.
6. Submitting bus selection reaches driver page.
7. Driver selection submit completes and returns to pending queue.
8. Allocation summary page renders with `summary` map data.

---

## Known constraints / assumptions
- Login currently uses demo credentials in servlet (`manager` / `manager123`).
- Some DAO methods are first-pass and may return empty data if DB has no matching rows.
- Driver assignment flow assumes bus has been staged via session in previous step.

If a JSP submit appears to do nothing, inspect redirect query params (`error=...` / `success=...`) and server logs.
