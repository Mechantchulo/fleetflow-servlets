<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%@ page import="com.transportmanager.model.Trip" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dean Dashboard - FleetFlow</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dean-dashboard.css">
</head>
<body>
    <div class="app-container">
        <aside class="sidebar">
            <div class="sidebar-header">
                <div class="logo-icon"><i class="fas fa-bus"></i></div>
                <h2>FleetFlow</h2>
            </div>
            
            <ul class="sidebar-menu">
                <li class="menu-item active">
                    <a href="${pageContext.request.contextPath}/dean/dashboard">
                        <i class="fas fa-border-all"></i>
                        <span>Dashboard</span>
                    </a>
                </li>
            </ul>

            <div class="sidebar-footer">
                <a href="${pageContext.request.contextPath}/login" class="logout-btn"> <i class="fas fa-sign-out-alt"></i>
                    <span>Logout</span>
                </a>
            </div>
        </aside>

        <main class="main-content">
            <header class="top-header">
                <div class="header-title">
                    <h1>Dean Overview</h1>
                    <p class="subtitle">Welcome back, ${username != null ? username : 'Dean'}</p>
                </div>
                <div class="header-profile">
                    <div class="profile-avatar">
                        <i class="fas fa-user-tie"></i>
                    </div>
                </div>
            </header>

            <div class="dashboard-content">
                
                <section class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-icon light-green-bg"><i class="fas fa-clock"></i></div>
                        <div class="stat-details">
                            <h3>${dashboardStats.pendingTrips}</h3>
                            <p>Pending Trips</p>
                            <span class="stat-meta">${dashboardStats.pendingPassengers} passengers waiting</span>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon success-bg"><i class="fas fa-check-circle"></i></div>
                        <div class="stat-details">
                            <h3>${dashboardStats.approvedTrips}</h3>
                            <p>Approved Trips</p>
                            <span class="stat-meta">Ready for allocation</span>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon info-bg"><i class="fas fa-calendar-day"></i></div>
                        <div class="stat-details">
                            <h3>${dashboardStats.todayTrips}</h3>
                            <p>Today's Trips</p>
                            <span class="stat-meta">Scheduled for today</span>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon secondary-bg"><i class="fas fa-bus"></i></div>
                        <div class="stat-details">
                            <h3>${dashboardStats.assignedTrips}</h3>
                            <p>Assigned Trips</p>
                            <span class="stat-meta">Vehicles & drivers ready</span>
                        </div>
                    </div>
                </section>

                <section class="utilization-section">
                    <div class="util-card">
                        <div class="card-header">
                            <h3><i class="fas fa-bus-alt"></i> Fleet Status</h3>
                        </div>
                        <div class="card-body grid-4">
                            <div class="data-block">
                                <h2 class="text-main">${fleetUtilization.totalVehicles}</h2>
                                <p>Total</p>
                            </div>
                            <div class="data-block">
                                <h2 class="text-success">${fleetUtilization.availableVehicles}</h2>
                                <p>Available</p>
                            </div>
                            <div class="data-block">
                                <h2 class="text-warning">${fleetUtilization.assignedVehicles}</h2>
                                <p>Assigned</p>
                            </div>
                            <div class="data-block">
                                <h2 class="text-danger">${fleetUtilization.maintenanceVehicles}</h2>
                                <p>Maintenance</p>
                            </div>
                        </div>
                    </div>

                    <div class="util-card">
                        <div class="card-header">
                            <h3><i class="fas fa-users"></i> Driver Status</h3>
                        </div>
                        <div class="card-body grid-3">
                            <div class="data-block">
                                <h2 class="text-main">${fleetUtilization.totalDrivers}</h2>
                                <p>Total</p>
                            </div>
                            <div class="data-block">
                                <h2 class="text-success">${fleetUtilization.availableDrivers}</h2>
                                <p>Available</p>
                            </div>
                            <div class="data-block">
                                <h2 class="text-warning">${fleetUtilization.assignedDrivers}</h2>
                                <p>On Duty</p>
                            </div>
                        </div>
                    </div>
                </section>

                <section class="table-card">
                    <div class="card-header">
                        <h3><i class="fas fa-route"></i> Recent Trip Requests</h3>
                    </div>
                    <div class="card-body">
                        <% 
                        List<Trip> recentTrips = (List<Trip>) request.getAttribute("recentTrips");
                        if (recentTrips != null && !recentTrips.isEmpty()) {
                        %>
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Trip ID</th>
                                    <th>Destination</th>
                                    <th>Requester</th>
                                    <th>Pax</th>
                                    <th>Priority</th>
                                    <th>Status</th>
                                    <th>Departure</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Trip trip : recentTrips) { %>
                                <tr>
                                    <td class="fw-600">#${trip.id}</td>
                                    <td>${trip.destination}</td>
                                    <td>${trip.requesterName}</td>
                                    <td>${trip.passengerCount}</td>
                                    <td>
                                        <span class="badge badge-priority-${trip.priority.toLowerCase()}">
                                            ${trip.priority}
                                        </span>
                                    </td>
                                    <td>
                                        <span class="badge badge-status-${trip.status.toLowerCase()}">
                                            ${trip.status}
                                        </span>
                                    </td>
                                    <td class="text-muted">${trip.departureDate}</td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                        <% } else { %>
                        <div class="empty-state">
                            <i class="fas fa-inbox"></i>
                            <p>No recent trip requests found.</p>
                        </div>
                        <% } %>
                    </div>
                </section>

            </div>
        </main>
    </div>

    <script src="${pageContext.request.contextPath}/js/dean-dashboard.js"></script>
</body>
</html>