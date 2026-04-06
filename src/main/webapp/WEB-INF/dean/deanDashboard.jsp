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
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container-fluid">
            <a class="navbar-brand" href="${pageContext.request.contextPath}/dean/dashboard">
                <i class="fas fa-bus me-2"></i>FleetFlow - Dean Portal
            </a>
            <div class="navbar-nav ms-auto">
                <span class="navbar-text me-3">
                    <i class="fas fa-user-tie me-1"></i>Dean
                </span>
                <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/dean/logout">
                    <i class="fas fa-sign-out-alt me-1"></i>Logout
                </a>
            </div>
        </div>
    </nav>

    <div class="container-fluid mt-4">
        <!-- Login Form (shown when not logged in) -->
        <% if (request.getAttribute("error") != null || session.getAttribute("userRole") == null) { %>
        <div class="row justify-content-center">
            <div class="col-md-6 col-lg-4">
                <div class="card shadow">
                    <div class="card-header bg-primary text-white">
                        <h5 class="mb-0"><i class="fas fa-lock me-2"></i>Dean Login</h5>
                    </div>
                    <div class="card-body">
                        <% if (request.getAttribute("error") != null) { %>
                        <div class="alert alert-danger" role="alert">
                            <i class="fas fa-exclamation-triangle me-2"></i>${error}
                        </div>
                        <% } %>
                        
                        <form method="post" action="${pageContext.request.contextPath}/dean/dashboard">
                            <div class="mb-3">
                                <label for="username" class="form-label">Username</label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="fas fa-user"></i></span>
                                    <input type="text" class="form-control" id="username" name="username" 
                                           value="${username}" placeholder="Enter username" required>
                                </div>
                            </div>
                            <div class="mb-3">
                                <label for="password" class="form-label">Password</label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="fas fa-lock"></i></span>
                                    <input type="password" class="form-control" id="password" name="password" 
                                           placeholder="Enter password" required>
                                </div>
                            </div>
                            <button type="submit" class="btn btn-primary w-100">
                                <i class="fas fa-sign-in-alt me-2"></i>Login
                            </button>
                        </form>
                        
                        <div class="mt-3 text-center text-muted small">
                            Demo credentials: dean / dean123
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <% } else { %>
        <!-- Dashboard Content (shown when logged in) -->
        
        <!-- Page Header -->
        <div class="row mb-4">
            <div class="col-12">
                <div class="d-flex justify-content-between align-items-center">
                    <h2><i class="fas fa-tachometer-alt me-2"></i>Dean Dashboard</h2>
                    <span class="text-muted">Fleet Management Overview</span>
                </div>
            </div>
        </div>

        <!-- Statistics Cards -->
        <div class="row mb-4">
            <div class="col-md-3 mb-3">
                <div class="card bg-warning text-white">
                    <div class="card-body">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h6 class="card-title">Pending Trips</h6>
                                <h3 class="mb-0">${dashboardStats.pendingTrips}</h3>
                            </div>
                            <div class="align-self-center">
                                <i class="fas fa-clock fa-2x opacity-75"></i>
                            </div>
                        </div>
                        <small>${dashboardStats.pendingPassengers} passengers waiting</small>
                    </div>
                </div>
            </div>
            
            <div class="col-md-3 mb-3">
                <div class="card bg-success text-white">
                    <div class="card-body">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h6 class="card-title">Approved Trips</h6>
                                <h3 class="mb-0">${dashboardStats.approvedTrips}</h3>
                            </div>
                            <div class="align-self-center">
                                <i class="fas fa-check-circle fa-2x opacity-75"></i>
                            </div>
                        </div>
                        <small>Ready for allocation</small>
                    </div>
                </div>
            </div>
            
            <div class="col-md-3 mb-3">
                <div class="card bg-info text-white">
                    <div class="card-body">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h6 class="card-title">Today's Trips</h6>
                                <h3 class="mb-0">${dashboardStats.todayTrips}</h3>
                            </div>
                            <div class="align-self-center">
                                <i class="fas fa-calendar-day fa-2x opacity-75"></i>
                            </div>
                        </div>
                        <small>Scheduled for today</small>
                    </div>
                </div>
            </div>
            
            <div class="col-md-3 mb-3">
                <div class="card bg-secondary text-white">
                    <div class="card-body">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h6 class="card-title">Assigned Trips</h6>
                                <h3 class="mb-0">${dashboardStats.assignedTrips}</h3>
                            </div>
                            <div class="align-self-center">
                                <i class="fas fa-bus fa-2x opacity-75"></i>
                            </div>
                        </div>
                        <small>Vehicles & drivers assigned</small>
                    </div>
                </div>
            </div>
        </div>

        <!-- Fleet Utilization -->
        <div class="row mb-4">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0"><i class="fas fa-bus me-2"></i>Vehicle Fleet Status</h5>
                    </div>
                    <div class="card-body">
                        <div class="row text-center">
                            <div class="col-3">
                                <div class="border rounded p-3">
                                    <h4 class="text-primary">${fleetUtilization.totalVehicles}</h4>
                                    <small class="text-muted">Total</small>
                                </div>
                            </div>
                            <div class="col-3">
                                <div class="border rounded p-3">
                                    <h4 class="text-success">${fleetUtilization.availableVehicles}</h4>
                                    <small class="text-muted">Available</small>
                                </div>
                            </div>
                            <div class="col-3">
                                <div class="border rounded p-3">
                                    <h4 class="text-warning">${fleetUtilization.assignedVehicles}</h4>
                                    <small class="text-muted">Assigned</small>
                                </div>
                            </div>
                            <div class="col-3">
                                <div class="border rounded p-3">
                                    <h4 class="text-danger">${fleetUtilization.maintenanceVehicles}</h4>
                                    <small class="text-muted">Maintenance</small>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0"><i class="fas fa-users me-2"></i>Driver Status</h5>
                    </div>
                    <div class="card-body">
                        <div class="row text-center">
                            <div class="col-4">
                                <div class="border rounded p-3">
                                    <h4 class="text-primary">${fleetUtilization.totalDrivers}</h4>
                                    <small class="text-muted">Total Drivers</small>
                                </div>
                            </div>
                            <div class="col-4">
                                <div class="border rounded p-3">
                                    <h4 class="text-success">${fleetUtilization.availableDrivers}</h4>
                                    <small class="text-muted">Available</small>
                                </div>
                            </div>
                            <div class="col-4">
                                <div class="border rounded p-3">
                                    <h4 class="text-warning">${fleetUtilization.assignedDrivers}</h4>
                                    <small class="text-muted">On Duty</small>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Recent Trips Overview -->
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0"><i class="fas fa-route me-2"></i>Recent Trip Requests</h5>
            </div>
            <div class="card-body">
                <% 
                List<Trip> recentTrips = (List<Trip>) request.getAttribute("recentTrips");
                if (recentTrips != null && !recentTrips.isEmpty()) {
                %>
                <div class="table-responsive">
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th>Trip ID</th>
                                <th>Destination</th>
                                <th>Requester</th>
                                <th>Passengers</th>
                                <th>Priority</th>
                                <th>Status</th>
                                <th>Departure</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Trip trip : recentTrips) { %>
                            <tr>
                                <td>#${trip.id}</td>
                                <td>${trip.destination}</td>
                                <td>${trip.requesterName}</td>
                                <td>${trip.passengerCount}</td>
                                <td>
                                    <span class="badge bg-${trip.priority == 'HIGH' ? 'danger' : trip.priority == 'MEDIUM' ? 'warning' : 'info'}">
                                        ${trip.priority}
                                    </span>
                                </td>
                                <td>
                                    <span class="badge bg-${trip.status == 'PENDING' ? 'warning' : trip.status == 'APPROVED' ? 'success' : trip.status == 'REJECTED' ? 'danger' : 'secondary'}">
                                        ${trip.status}
                                    </span>
                                </td>
                                <td>${trip.departureDate}</td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
                <% } else { %>
                <div class="text-center text-muted py-4">
                    <i class="fas fa-inbox fa-3x mb-3"></i>
                    <p>No recent trip requests found.</p>
                </div>
                <% } %>
            </div>
        </div>
        <% } %>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
