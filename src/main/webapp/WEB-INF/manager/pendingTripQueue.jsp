<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.transportmanager.model.Trip" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pending Trips - ATMS</title>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/manager-dashboard.css">
</head>
<body>
<div class="app-container">
    <aside class="sidebar">
        <div class="sidebar-header">
            <div class="logo-icon"><i class="fas fa-bus"></i></div>
            <h2>ATMS</h2>
        </div>
        <ul class="sidebar-menu">
            <li class="menu-item">
                <a href="${pageContext.request.contextPath}/manager/dashboard"><i class="fas fa-chart-pie"></i><span>Overview</span></a>
            </li>
            <li class="menu-item active">
                <a href="${pageContext.request.contextPath}/manager/trips/pending"><i class="fas fa-list-check"></i><span>Pending Queue</span></a>
            </li>
            <li class="menu-item"><a href="${pageContext.request.contextPath}/manager/drivers"><i class="fas fa-id-card"></i><span>Manage Drivers</span></a></li>
            <li class="menu-item">
                <a href="${pageContext.request.contextPath}/manager/timetables/submitted"><i class="fas fa-calendar-check"></i><span>Submitted Timetables</span></a>
            </li>
            <li class="menu-item">
                <a href="${pageContext.request.contextPath}/manager/reports/summary"><i class="fas fa-chart-line"></i><span>Reports</span></a>
            </li>
        </ul>
        <div class="sidebar-footer">
            <a href="${pageContext.request.contextPath}/manager/logout" class="logout-btn"><i class="fas fa-sign-out-alt"></i><span>Logout</span></a>
        </div>
    </aside>

    <main class="main-content">
        <header class="top-header">
            <div class="header-title">
                <h1>Pending Trip Queue</h1>
                <p class="subtitle">Review requests, confirm decisions, and dispatch resources</p>
            </div>
            <div class="profile-avatar"><i class="fas fa-user-cog"></i></div>
        </header>

        <div class="dashboard-content">
            <% String error = request.getParameter("error"); %>
            <% String success = request.getParameter("success"); %>
            <% if (error != null) { %>
            <div class="error-alert"><i class="fas fa-exclamation-circle"></i>Action failed: <%= error %></div>
            <% } %>
            <% if (success != null) { %>
            <div class="error-alert" style="background:#dcfce7;border-left-color:#16a34a;color:#166534;"><i class="fas fa-check-circle"></i>Action complete: <%= success %></div>
            <% } %>

            <section class="filter-card">
                <div class="card-header"><h3><i class="fas fa-filter"></i>Filter Queue</h3></div>
                <form method="get" action="${pageContext.request.contextPath}/manager/trips/pending" class="filter-form">
                    <div class="form-group">
                        <label for="priority">Priority</label>
                        <select id="priority" name="priority" class="form-control">
                            <option value="" ${empty priority ? 'selected' : ''}>All</option>
                            <option value="HIGH" ${priority == 'HIGH' ? 'selected' : ''}>High</option>
                            <option value="MEDIUM" ${priority == 'MEDIUM' ? 'selected' : ''}>Medium</option>
                            <option value="LOW" ${priority == 'LOW' ? 'selected' : ''}>Low</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="dateFrom">Date From</label>
                        <input id="dateFrom" name="dateFrom" type="date" class="form-control" value="${dateFrom}">
                    </div>
                    <div class="form-group">
                        <label for="dateTo">Date To</label>
                        <input id="dateTo" name="dateTo" type="date" class="form-control" value="${dateTo}">
                    </div>
                    <div class="form-group">
                        <label for="size">Rows</label>
                        <input id="size" name="size" type="number" min="1" max="100" class="form-control" value="${size}">
                    </div>
                    <div class="filter-actions">
                        <button class="btn btn-primary" type="submit">Apply</button>
                        <a class="btn btn-outline" href="${pageContext.request.contextPath}/manager/trips/pending">Reset</a>
                    </div>
                </form>
            </section>

            <section class="table-card">
                <div class="card-header">
                    <h3><i class="fas fa-inbox"></i>Pending/Approved/Confirmed Requests</h3>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="data-table">
                            <thead>
                            <tr>
                                <th>ID</th>
                                <th>Requester</th>
                                <th>Department</th>
                                <th>Destination</th>
                                <th>Departure</th>
                                <th>Pax</th>
                                <th>Priority</th>
                                <th>Status</th>
                                <th>Manager Decision</th>
                                <th>Allocation</th>
                            </tr>
                            </thead>
                            <tbody>
                            <%
                                List<Trip> trips = (List<Trip>) request.getAttribute("pendingTrips");
                                if (trips == null || trips.isEmpty()) {
                            %>
                            <tr><td colspan="10" class="text-muted">No trips found for selected filters.</td></tr>
                            <% } else {
                                for (Trip trip : trips) {
                                    String priorityValue = trip.getPriority() == null ? "LOW" : trip.getPriority();
                                    String statusValue = trip.getStatus() == null ? "PENDING" : trip.getStatus();
                                    String statusClass;
                                    if ("APPROVED".equalsIgnoreCase(statusValue) || "CONFIRMED".equalsIgnoreCase(statusValue)) {
                                        statusClass = "approved";
                                    } else if ("REJECTED".equalsIgnoreCase(statusValue)) {
                                        statusClass = "rejected";
                                    } else if ("ASSIGNED".equalsIgnoreCase(statusValue)) {
                                        statusClass = "assigned";
                                    } else {
                                        statusClass = "pending";
                                    }
                            %>
                            <tr>
                                <td class="fw-600"><%= trip.getId() %></td>
                                <td><%= trip.getRequesterName() == null ? "-" : trip.getRequesterName() %></td>
                                <td><%= trip.getDepartment() == null ? "-" : trip.getDepartment() %></td>
                                <td><%= trip.getDestination() == null ? "-" : trip.getDestination() %></td>
                                <td><%= trip.getDepartureDate() == null ? "-" : trip.getDepartureDate() %></td>
                                <td><%= trip.getPassengerCount() %></td>
                                <td><span class="badge badge-priority-<%= priorityValue.toLowerCase() %>"><%= priorityValue %></span></td>
                                <td><span class="badge badge-status-<%= statusClass %>"><%= statusValue %></span></td>
                                <td>
                                    <form method="post" action="${pageContext.request.contextPath}/manager/trips/decision">
                                        <input type="hidden" name="tripId" value="<%= trip.getId() %>">
                                        <textarea name="managerNote" class="note-field" placeholder="Optional manager note"></textarea>
                                        <div style="display:flex;gap:8px;margin-top:8px;flex-wrap:wrap;">
                                            <button type="submit" class="btn-approve" name="action" value="CONFIRM">Confirm</button>
                                            <button type="submit" class="btn-reject" name="action" value="REJECT">Reject</button>
                                        </div>
                                    </form>
                                </td>
                                <td>
                                    <a class="btn-allocate-sm" href="${pageContext.request.contextPath}/manager/allocation/buses?tripId=<%= trip.getId() %>">
                                        Allocate Bus
                                    </a>
                                </td>
                            </tr>
                            <% }
                            } %>
                            </tbody>
                        </table>
                    </div>
                    <div class="card-body">
                        <div class="pagination-container">
                            <a class="btn btn-outline" href="${pageContext.request.contextPath}/manager/trips/pending?page=${page > 1 ? page - 1 : 1}&size=${size}&priority=${priority}&dateFrom=${dateFrom}&dateTo=${dateTo}">Prev</a>
                            <span class="page-indicator">Page ${page}</span>
                            <a class="btn btn-outline" href="${pageContext.request.contextPath}/manager/trips/pending?page=${page + 1}&size=${size}&priority=${priority}&dateFrom=${dateFrom}&dateTo=${dateTo}">Next</a>
                        </div>
                    </div>
                </div>
            </section>
        </div>
    </main>
</div>
</body>
</html>
