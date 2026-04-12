<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.transportmanager.model.Bus" %>
<%@ page import="com.transportmanager.model.Trip" %>
<%
    Trip trip = (Trip) request.getAttribute("trip");
    Integer requiredCapacity = (Integer) request.getAttribute("requiredCapacity");
    Long tripId = (Long) request.getAttribute("tripId");
    List<Bus> availableBuses = (List<Bus>) request.getAttribute("availableBuses");
    if (availableBuses == null) {
        availableBuses = java.util.Collections.emptyList();
    }
    if (requiredCapacity == null) {
        requiredCapacity = 0;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Allocate Bus - ATMS</title>
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
                <h1>Select Bus</h1>
                <p class="subtitle">Step 1 of 2: choose a bus for trip <%= tripId == null ? "-" : tripId %></p>
            </div>
            <div class="profile-avatar"><i class="fas fa-bus-alt"></i></div>
        </header>

        <div class="dashboard-content">
            <% String error = request.getParameter("error");
               if (error != null) { %>
                <div class="error-alert"><i class="fas fa-exclamation-circle"></i>Error: <%= error %></div>
            <% } %>

            <% if (trip != null) { %>
            <section class="card" style="margin-bottom: 24px;">
                <div class="card-header"><h3><i class="fas fa-circle-info"></i>Trip Information</h3></div>
                <div class="card-body">
                    <div class="stats-grid" style="margin-bottom:0;">
                        <div class="stat-card"><div class="stat-icon info-bg"><i class="fas fa-location-dot"></i></div><div class="stat-details"><h3 style="font-size:1.1rem;"><%= trip.getDestination() == null ? "-" : trip.getDestination() %></h3><p>Destination</p></div></div>
                        <div class="stat-card"><div class="stat-icon secondary-bg"><i class="fas fa-user"></i></div><div class="stat-details"><h3 style="font-size:1.1rem;"><%= trip.getRequesterName() == null ? "-" : trip.getRequesterName() %></h3><p>Requester</p></div></div>
                        <div class="stat-card"><div class="stat-icon pending-bg"><i class="fas fa-users"></i></div><div class="stat-details"><h3><%= trip.getPassengerCount() %></h3><p>Passengers</p></div></div>
                        <div class="stat-card"><div class="stat-icon light-green-bg"><i class="fas fa-bus"></i></div><div class="stat-details"><h3><%= requiredCapacity %></h3><p>Required Capacity</p></div></div>
                    </div>
                </div>
            </section>
            <% } %>

            <section class="card">
                <div class="card-header"><h3><i class="fas fa-list"></i>Available Buses</h3></div>
                <div class="card-body">
                    <% if (availableBuses.isEmpty()) { %>
                        <div class="empty-state">
                            <div class="empty-icon pending-bg"><i class="fas fa-bus"></i></div>
                            <h3>No buses currently available</h3>
                            <p>Try changing filters or apply a soft override if policy allows.</p>
                            <a class="btn btn-outline mt-3" href="${pageContext.request.contextPath}/manager/trips/pending">Back to Queue</a>
                        </div>
                    <% } else { %>
                        <form method="post" action="${pageContext.request.contextPath}/manager/allocation/bus/assign" id="busForm">
                            <input type="hidden" name="tripId" value="<%= tripId %>">
                            <div class="table-responsive">
                                <table class="data-table">
                                    <thead>
                                    <tr>
                                        <th>Select</th>
                                        <th>Plate Number</th>
                                        <th>Capacity</th>
                                        <th>Mileage</th>
                                        <th>Status</th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <% for (Bus bus : availableBuses) {
                                        boolean enough = bus.getCapacity() >= requiredCapacity;
                                    %>
                                    <tr>
                                        <td><input type="radio" name="busId" value="<%= bus.getId() %>" required></td>
                                        <td class="fw-600"><%= bus.getPlateNumber() == null ? "-" : bus.getPlateNumber() %></td>
                                        <td>
                                            <%= bus.getCapacity() %>
                                            <% if (!enough) { %><span class="badge badge-priority-high" style="margin-left:8px;">Below Need</span><% } %>
                                        </td>
                                        <td><%= bus.getMileage() %> km</td>
                                        <td><span class="badge badge-status-approved"><%= bus.getStatus() == null ? "AVAILABLE" : bus.getStatus() %></span></td>
                                    </tr>
                                    <% } %>
                                    </tbody>
                                </table>
                            </div>

                            <div class="card" style="margin-top:20px;">
                                <div class="card-header"><h3><i class="fas fa-shield"></i>Soft Override (Optional)</h3></div>
                                <div class="card-body">
                                    <div class="form-group">
                                        <label style="text-transform:none;letter-spacing:0;display:flex;gap:10px;align-items:center;">
                                            <input type="checkbox" id="overrideCheck" name="override" value="true">
                                            Apply override if selected bus conflicts with availability rules
                                        </label>
                                    </div>
                                    <div class="form-group" id="reasonWrap" style="display:none;">
                                        <label for="overrideReason">Override Reason</label>
                                        <textarea id="overrideReason" name="overrideReason" class="form-control" placeholder="Explain why override is needed"></textarea>
                                    </div>
                                </div>
                            </div>

                            <div class="filter-actions" style="margin-top:18px;justify-content:flex-end;">
                                <a class="btn btn-outline" href="${pageContext.request.contextPath}/manager/trips/pending">Back</a>
                                <button class="btn btn-primary" type="submit">Continue to Driver Selection</button>
                            </div>
                        </form>
                    <% } %>
                </div>
            </section>
        </div>
    </main>
</div>

<script>
    const overrideCheck = document.getElementById('overrideCheck');
    const reasonWrap = document.getElementById('reasonWrap');
    if (overrideCheck) {
        overrideCheck.addEventListener('change', function () {
            reasonWrap.style.display = this.checked ? 'block' : 'none';
        });
    }
</script>
</body>
</html>
