<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.transportmanager.model.Driver" %>
<%@ page import="com.transportmanager.model.Trip" %>
<%
    Trip trip = (Trip) request.getAttribute("trip");
    Long selectedBusId = (Long) request.getAttribute("selectedBusId");
    Long tripId = (Long) request.getAttribute("tripId");
    Boolean override = (Boolean) request.getAttribute("override");
    String overrideReason = (String) request.getAttribute("overrideReason");
    List<Driver> availableDrivers = (List<Driver>) request.getAttribute("availableDrivers");
    if (availableDrivers == null) {
        availableDrivers = java.util.Collections.emptyList();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Allocate Driver - ATMS</title>
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
                <h1>Select Driver</h1>
                <p class="subtitle">Step 2 of 2: choose the driver and complete allocation</p>
            </div>
            <div class="profile-avatar"><i class="fas fa-id-card"></i></div>
        </header>

        <div class="dashboard-content">
            <% String error = request.getParameter("error");
               if (error != null) { %>
            <div class="error-alert"><i class="fas fa-exclamation-circle"></i>Error: <%= error %></div>
            <% }
               if (request.getParameter("success") != null) { %>
            <div class="error-alert" style="background:#dcfce7;border-left-color:#16a34a;color:#166534;"><i class="fas fa-check-circle"></i>Bus selected successfully. Pick a driver to finish allocation.</div>
            <% } %>

            <section class="card" style="margin-bottom:24px;">
                <div class="card-header"><h3><i class="fas fa-circle-info"></i>Allocation Context</h3></div>
                <div class="card-body">
                    <div class="stats-grid" style="margin-bottom:0;">
                        <div class="stat-card"><div class="stat-icon info-bg"><i class="fas fa-hashtag"></i></div><div class="stat-details"><h3><%= trip == null ? "-" : trip.getId() %></h3><p>Trip ID</p></div></div>
                        <div class="stat-card"><div class="stat-icon secondary-bg"><i class="fas fa-location-dot"></i></div><div class="stat-details"><h3 style="font-size:1.1rem;"><%= trip == null || trip.getDestination() == null ? "-" : trip.getDestination() %></h3><p>Destination</p></div></div>
                        <div class="stat-card"><div class="stat-icon pending-bg"><i class="fas fa-users"></i></div><div class="stat-details"><h3><%= trip == null ? 0 : trip.getPassengerCount() %></h3><p>Passengers</p></div></div>
                        <div class="stat-card"><div class="stat-icon light-green-bg"><i class="fas fa-bus"></i></div><div class="stat-details"><h3><%= selectedBusId == null ? "-" : selectedBusId %></h3><p>Selected Bus ID</p></div></div>
                    </div>
                </div>
            </section>

            <section class="card">
                <div class="card-header"><h3><i class="fas fa-user-check"></i>Available Drivers</h3></div>
                <div class="card-body">
                    <% if (availableDrivers.isEmpty()) { %>
                        <div class="empty-state">
                            <div class="empty-icon pending-bg"><i class="fas fa-user-slash"></i></div>
                            <h3>No drivers available</h3>
                            <p>Go back and select another bus later, or register a newly approved driver.</p>
                            <div class="filter-actions" style="justify-content:center;margin-top:12px;">
                                <a class="btn btn-outline mt-3" href="${pageContext.request.contextPath}/manager/allocation/buses?tripId=<%= tripId %>">Back to Buses</a>
                                <a class="btn btn-primary mt-3" href="${pageContext.request.contextPath}/manager/drivers">Manage Drivers</a>
                            </div>
                        </div>
                    <% } else { %>
                    <form method="post" action="${pageContext.request.contextPath}/manager/allocation/driver/assign">
                        <input type="hidden" name="tripId" value="<%= tripId %>">
                        <input type="hidden" name="override" value="<%= override != null && override ? "true" : "false" %>">
                        <input type="hidden" name="overrideReason" value="<%= overrideReason == null ? "" : overrideReason %>">

                        <div class="table-responsive">
                            <table class="data-table">
                                <thead>
                                <tr>
                                    <th>Select</th>
                                    <th>Full Name</th>
                                    <th>License Number</th>
                                    <th>Status</th>
                                </tr>
                                </thead>
                                <tbody>
                                <% for (Driver driver : availableDrivers) { %>
                                <tr>
                                    <td><input type="radio" name="driverId" value="<%= driver.getId() %>" required></td>
                                    <td class="fw-600"><%= driver.getFullName() == null ? "-" : driver.getFullName() %></td>
                                    <td><%= driver.getLicenseNumber() == null ? "-" : driver.getLicenseNumber() %></td>
                                    <td><span class="badge badge-status-approved"><%= driver.getStatus() == null ? "AVAILABLE" : driver.getStatus() %></span></td>
                                </tr>
                                <% } %>
                                </tbody>
                            </table>
                        </div>

                        <% if (override != null && override) { %>
                        <div class="card" style="margin-top:20px;">
                            <div class="card-header"><h3><i class="fas fa-triangle-exclamation"></i>Bus Override Active</h3></div>
                            <div class="card-body">
                                <p class="text-muted">The bus step used an override. Reason:</p>
                                <p class="fw-600"><%= overrideReason == null || overrideReason.isBlank() ? "No reason provided" : overrideReason %></p>
                            </div>
                        </div>
                        <% } %>

                        <div class="filter-actions" style="margin-top:18px;justify-content:flex-end;">
                            <a class="btn btn-outline" href="${pageContext.request.contextPath}/manager/allocation/buses?tripId=<%= tripId %>">Back</a>
                            <button class="btn btn-primary" type="submit">Complete Allocation</button>
                        </div>
                    </form>
                    <% } %>
                </div>
            </section>
        </div>
    </main>
</div>
</body>
</html>
