<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.transportmanager.model.Trip" %>
<%
    List<Trip> trips = (List<Trip>) request.getAttribute("pendingTrips");
    if (trips == null) {
        trips = java.util.Collections.emptyList();
    }

    int pendingCount = trips.size();
    int highPriorityCount = 0;
    int passengersWaiting = 0;
    for (Trip trip : trips) {
        if (trip != null) {
            passengersWaiting += Math.max(0, trip.getPassengerCount());
            if ("HIGH".equalsIgnoreCase(trip.getPriority())) {
                highPriorityCount++;
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manager Overview - ATMS</title>
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
            <li class="menu-item active">
                <a href="${pageContext.request.contextPath}/manager/dashboard">
                    <i class="fas fa-chart-pie"></i><span>Overview</span>
                </a>
            </li>
            <li class="menu-item">
                <a href="${pageContext.request.contextPath}/manager/trips/pending">
                    <i class="fas fa-list-check"></i><span>Pending Queue</span>
                </a>
            </li>
            <li class="menu-item">
                <a href="${pageContext.request.contextPath}/manager/drivers">
                    <i class="fas fa-id-card"></i><span>Manage Drivers</span>
                </a>
            </li>
            <li class="menu-item">
                <a href="${pageContext.request.contextPath}/manager/timetables/submitted">
                    <i class="fas fa-calendar-check"></i><span>Submitted Timetables</span>
                </a>
            </li>
            <li class="menu-item">
                <a href="${pageContext.request.contextPath}/manager/reports/summary">
                    <i class="fas fa-chart-line"></i><span>Monthly Reports</span>
                </a>
            </li>
        </ul>

        <div class="sidebar-footer">
            <a href="${pageContext.request.contextPath}/manager/logout" class="logout-btn">
                <i class="fas fa-sign-out-alt"></i><span>Logout</span>
            </a>
        </div>
    </aside>

    <main class="main-content">
        <header class="top-header">
            <div class="header-title">
                <h1>Transport Manager Dashboard</h1>
                <p class="subtitle">Welcome, ${sessionScope.managerUsername != null ? sessionScope.managerUsername : 'manager'}</p>
            </div>
            <div class="profile-avatar"><i class="fas fa-user-cog"></i></div>
        </header>

        <div class="dashboard-content">
            <div class="filter-actions" style="justify-content:flex-end;margin-bottom:16px;">
                <a class="btn btn-outline" href="${pageContext.request.contextPath}/manager/reports/pdf">Export Manager PDF</a>
            </div>
            <% if (highPriorityCount > 0) { %>
            <div class="urgent-alert">
                <div class="urgent-text">
                    <i class="fas fa-triangle-exclamation"></i>
                    <span><strong><%= highPriorityCount %></strong> high-priority trips need review.</span>
                </div>
                <a class="btn btn-danger" href="${pageContext.request.contextPath}/manager/trips/pending?priority=HIGH">Open Queue</a>
            </div>
            <% } %>

            <section class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon pending-bg"><i class="fas fa-inbox"></i></div>
                    <div class="stat-details">
                        <h3><%= pendingCount %></h3>
                        <p>Pending/Confirmed Trips</p>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon danger-bg"><i class="fas fa-fire"></i></div>
                    <div class="stat-details">
                        <h3><%= highPriorityCount %></h3>
                        <p>High Priority</p>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon info-bg"><i class="fas fa-users"></i></div>
                    <div class="stat-details">
                        <h3><%= passengersWaiting %></h3>
                        <p>Passengers Waiting</p>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon success-bg"><i class="fas fa-calendar-days"></i></div>
                    <div class="stat-details">
                        <h3>${dateFrom != null || dateTo != null ? 'Filtered' : 'Default'}</h3>
                        <p>Queue Scope</p>
                    </div>
                </div>
            </section>

            <section class="action-cards">
                <a href="${pageContext.request.contextPath}/manager/trips/pending" class="action-card">
                    <div class="action-icon light-green-bg"><i class="fas fa-route"></i></div>
                    <h3>Process Trip Queue</h3>
                    <p>Confirm, reject, and allocate buses and drivers for requests.</p>
                </a>
                <a href="${pageContext.request.contextPath}/manager/reports/summary" class="action-card">
                    <div class="action-icon info-bg"><i class="fas fa-file-lines"></i></div>
                    <h3>Generate Reports</h3>
                    <p>View monthly summaries or choose a custom date range.</p>
                </a>
                <a href="${pageContext.request.contextPath}/manager/timetables/submitted" class="action-card">
                    <div class="action-icon secondary-bg"><i class="fas fa-calendar-check"></i></div>
                    <h3>Review Timetable Submissions</h3>
                    <p>Validate submitted trips and activate them for allocation queue.</p>
                </a>
                <a href="${pageContext.request.contextPath}/manager/trips/pending?priority=HIGH" class="action-card">
                    <div class="action-icon pending-bg"><i class="fas fa-bolt"></i></div>
                    <h3>Handle Urgent Trips</h3>
                    <p>Jump directly to urgent trips with larger passenger demand.</p>
                </a>
            </section>

            <section class="card">
                <div class="card-header"><h3><i class="fas fa-list-ul"></i>Next Trips in Queue</h3></div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="data-table">
                            <thead>
                            <tr>
                                <th>ID</th>
                                <th>Destination</th>
                                <th>Departure</th>
                                <th>Passengers</th>
                                <th>Priority</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                            </thead>
                            <tbody>
                            <% if (trips.isEmpty()) { %>
                            <tr><td colspan="7" class="text-muted">No trips available in the current queue.</td></tr>
                            <% } else {
                                int cap = Math.min(8, trips.size());
                                for (int i = 0; i < cap; i++) {
                                    Trip trip = trips.get(i);
                            %>
                            <tr>
                                <td class="fw-600"><%= trip.getId() %></td>
                                <td><%= trip.getDestination() == null ? "-" : trip.getDestination() %></td>
                                <td><%= trip.getDepartureDate() == null ? "-" : trip.getDepartureDate() %></td>
                                <td><%= trip.getPassengerCount() %></td>
                                <td><span class="badge badge-priority-<%= trip.getPriority() == null ? "low" : trip.getPriority().toLowerCase() %>"><%= trip.getPriority() == null ? "LOW" : trip.getPriority() %></span></td>
                                <td><span class="badge badge-status-<%= trip.getStatus() == null ? "pending" : trip.getStatus().toLowerCase() %>"><%= trip.getStatus() == null ? "PENDING" : trip.getStatus() %></span></td>
                                <td><a class="btn-action" href="${pageContext.request.contextPath}/manager/allocation/buses?tripId=<%= trip.getId() %>"><i class="fas fa-arrow-right"></i>Allocate</a></td>
                            </tr>
                            <% }
                            } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </section>
        </div>
    </main>
</div>
</body>
</html>
