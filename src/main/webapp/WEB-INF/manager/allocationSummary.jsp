<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.Map" %>
<%
    Map<String, Object> summary = (Map<String, Object>) request.getAttribute("summary");
    Long tripId = (Long) request.getAttribute("tripId");
    if (summary == null) {
        summary = java.util.Collections.emptyMap();
    }

    String tripStatus = String.valueOf(summary.getOrDefault("tripStatus", "PENDING"));
    String destination = String.valueOf(summary.getOrDefault("destination", "-"));
    String departureTime = String.valueOf(summary.getOrDefault("departureTime", "-"));
    String passengerCount = String.valueOf(summary.getOrDefault("passengerCount", 0));
    String assignmentStatus = String.valueOf(summary.getOrDefault("assignmentStatus", "UNASSIGNED"));
    String plateNumber = String.valueOf(summary.getOrDefault("plateNumber", "-"));
    String driverName = String.valueOf(summary.getOrDefault("driverName", "-"));
    String managerName = String.valueOf(summary.getOrDefault("managerName", "-"));
    boolean overrideUsed = Boolean.parseBoolean(String.valueOf(summary.getOrDefault("overrideUsed", false)));
    String overrideReason = String.valueOf(summary.getOrDefault("overrideReason", ""));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Allocation Summary - ATMS</title>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/manager-dashboard.css">
</head>
<body>
<div class="app-container">
    <aside class="sidebar">
        <div class="sidebar-header"><div class="logo-icon"><i class="fas fa-bus"></i></div><h2>ATMS</h2></div>
        <ul class="sidebar-menu">
            <li class="menu-item"><a href="${pageContext.request.contextPath}/manager/dashboard"><i class="fas fa-chart-pie"></i><span>Overview</span></a></li>
            <li class="menu-item active"><a href="${pageContext.request.contextPath}/manager/trips/pending"><i class="fas fa-list-check"></i><span>Pending Queue</span></a></li>
            <li class="menu-item"><a href="${pageContext.request.contextPath}/manager/drivers"><i class="fas fa-id-card"></i><span>Manage Drivers</span></a></li>
            <li class="menu-item">
                <a href="${pageContext.request.contextPath}/manager/timetables/submitted"><i class="fas fa-calendar-check"></i><span>Submitted Timetables</span></a></li>
            <li class="menu-item"><a href="${pageContext.request.contextPath}/manager/reports/summary"><i class="fas fa-chart-line"></i><span>Reports</span></a></li>
        </ul>
        <div class="sidebar-footer"><a href="${pageContext.request.contextPath}/manager/logout" class="logout-btn"><i class="fas fa-sign-out-alt"></i><span>Logout</span></a></div>
    </aside>

    <main class="main-content">
        <header class="top-header">
            <div class="header-title">
                <h1>Allocation Summary</h1>
                <p class="subtitle">Trip <%= tripId == null ? "-" : tripId %> allocation details and override controls</p>
            </div>
            <div class="profile-avatar"><i class="fas fa-circle-check"></i></div>
        </header>

        <div class="dashboard-content">
            <% if (request.getParameter("success") != null) { %>
            <div class="error-alert" style="background:#dcfce7;border-left-color:#16a34a;color:#166534;"><i class="fas fa-check-circle"></i>Success: <%= request.getParameter("success") %></div>
            <% } %>

            <section class="stats-grid">
                <div class="stat-card"><div class="stat-icon info-bg"><i class="fas fa-hashtag"></i></div><div class="stat-details"><h3><%= tripId == null ? "-" : tripId %></h3><p>Trip ID</p></div></div>
                <div class="stat-card"><div class="stat-icon pending-bg"><i class="fas fa-users"></i></div><div class="stat-details"><h3><%= passengerCount %></h3><p>Passengers</p></div></div>
                <div class="stat-card"><div class="stat-icon light-green-bg"><i class="fas fa-route"></i></div><div class="stat-details"><h3 style="font-size:1.1rem;"><%= destination %></h3><p>Destination</p></div></div>
                <div class="stat-card"><div class="stat-icon success-bg"><i class="fas fa-clipboard-check"></i></div><div class="stat-details"><h3 style="font-size:1.1rem;"><%= assignmentStatus %></h3><p>Assignment Status</p></div></div>
            </section>

            <section class="card" style="margin-bottom:24px;">
                <div class="card-header"><h3><i class="fas fa-link"></i>Assigned Resources</h3></div>
                <div class="card-body p-0">
                    <table class="data-table">
                        <tbody>
                        <tr><td class="fw-600">Trip Status</td><td><span class="badge badge-status-approved"><%= tripStatus %></span></td></tr>
                        <tr><td class="fw-600">Departure Time</td><td><%= departureTime %></td></tr>
                        <tr><td class="fw-600">Assigned Bus</td><td><%= plateNumber %></td></tr>
                        <tr><td class="fw-600">Assigned Driver</td><td><%= driverName %></td></tr>
                        <tr><td class="fw-600">Allocated By</td><td><%= managerName %></td></tr>
                        <tr><td class="fw-600">Override Used</td><td><span class="badge <%= overrideUsed ? "badge-priority-high" : "badge-status-approved" %>"><%= overrideUsed ? "YES" : "NO" %></span></td></tr>
                        <% if (overrideUsed) { %>
                        <tr><td class="fw-600">Override Reason</td><td><%= overrideReason == null || overrideReason.isBlank() ? "-" : overrideReason %></td></tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </section>

            <section class="card" style="margin-bottom:24px;">
                <div class="card-header"><h3><i class="fas fa-shield"></i>Apply Soft Override</h3></div>
                <div class="card-body">
                    <form method="post" action="${pageContext.request.contextPath}/manager/allocation/override">
                        <input type="hidden" name="tripId" value="<%= tripId %>">
                        <div class="filter-form" style="padding:0;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));">
                            <div class="form-group">
                                <label for="overrideType">Override Type</label>
                                <select id="overrideType" name="overrideType" class="form-control" required>
                                    <option value="BUS">Bus</option>
                                    <option value="DRIVER">Driver</option>
                                    <option value="ASSIGNMENT">Assignment</option>
                                </select>
                            </div>
                            <div class="form-group">
                                <label for="targetId">Target ID</label>
                                <input id="targetId" type="number" min="1" name="targetId" class="form-control" placeholder="Bus/Driver ID (required for BUS/DRIVER)">
                            </div>
                            <div class="form-group" style="grid-column:1 / -1;">
                                <label for="reason">Reason</label>
                                <textarea id="reason" name="reason" class="form-control" required placeholder="Why is this override needed?"></textarea>
                            </div>
                        </div>
                        <div class="filter-actions" style="justify-content:flex-end;">
                            <button class="btn btn-primary" type="submit">Save Override</button>
                        </div>
                    </form>
                </div>
            </section>

            <div class="filter-actions" style="justify-content:flex-end;">
                <a class="btn btn-outline" href="${pageContext.request.contextPath}/manager/trips/pending">Back to Pending Queue</a>
                <a class="btn btn-primary" href="${pageContext.request.contextPath}/manager/allocation/buses?tripId=<%= tripId %>">Re-run Allocation</a>
            </div>
        </div>
    </main>
</div>
</body>
</html>
