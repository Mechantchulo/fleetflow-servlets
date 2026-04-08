<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.driver.driverdashboard.Trip" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Driver Dashboard - FleetFlow</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/driver-dashboard.css">
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
                    <a href="${pageContext.request.contextPath}/driver/dashboard">
                        <i class="fas fa-steering-wheel"></i>
                        <span>My Dashboard</span>
                    </a>
                </li>
                <li class="menu-item">
                    <a href="#">
                        <i class="fas fa-gas-pump"></i>
                        <span>Fuel Logs</span>
                    </a>
                </li>
                <li class="menu-item">
                    <a href="#">
                        <i class="fas fa-clipboard-list"></i>
                        <span>Trip Logs</span>
                    </a>
                </li>
            </ul>

            <div class="sidebar-footer">
                <a href="${pageContext.request.contextPath}/login" class="logout-btn">
                    <i class="fas fa-sign-out-alt"></i>
                    <span>Logout</span>
                </a>
            </div>
        </aside>

        <main class="main-content">
            <header class="top-header">
                <div class="header-title">
                    <h1>Driver Portal</h1>
                    <p class="subtitle">Welcome back, ${sessionScope.username != null ? sessionScope.username : 'Driver'}</p>
                </div>
                <div class="header-profile">
                    <div class="profile-avatar">
                        <i class="fas fa-id-badge"></i>
                    </div>
                </div>
            </header>

            <div class="dashboard-content">

                <% if (session.getAttribute("error") != null) { %>
                <div class="error-alert">
                    <i class="fas fa-exclamation-circle"></i> <%= session.getAttribute("error") %>
                </div>
                <% session.removeAttribute("error"); } %>

                <div class="content-split">
                    <div class="form-section">
                        <div class="card form-card">
                            <div class="card-header">
                                <h3><i class="fas fa-plus-circle"></i> Log a New Trip</h3>
                            </div>
                            <div class="card-body">
                                <form method="post" action="${pageContext.request.contextPath}/driver/dashboard" id="tripForm">
                                    <div class="form-group">
                                        <label for="destination">Destination</label>
                                        <input type="text" name="destination" id="destination" class="form-control" placeholder="e.g., Nairobi Central" required>
                                    </div>
                                    
                                    <div class="form-group">
                                        <label for="date">Trip Date</label>
                                        <input type="date" name="date" id="date" class="form-control" required>
                                    </div>

                                    <div class="form-group">
                                        <label for="passengers">Number of Passengers</label>
                                        <input type="number" name="passengers" id="passengers" class="form-control" min="1" max="100" placeholder="e.g., 25" required>
                                    </div>

                                    <button type="submit" class="btn btn-primary w-100 mt-3">
                                        <i class="fas fa-save"></i> Save Trip Log
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>

                    <div class="history-section">
                        <div class="card table-card">
                            <div class="card-header d-flex-between">
                                <h3><i class="fas fa-history"></i> My Recent Trips</h3>
                                <span class="badge badge-assigned">Assigned to You</span>
                            </div>
                            <div class="card-body p-0">
                                <% 
                                List<Trip> tripsList = (List<Trip>) request.getAttribute("trips");
                                if (tripsList != null && !tripsList.isEmpty()) {
                                %>
                                <div class="table-responsive">
                                    <table class="data-table">
                                        <thead>
                                            <tr>
                                                <th>Trip ID</th>
                                                <th>Destination</th>
                                                <th>Date</th>
                                                <th>Pax</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <% for (Trip trip : tripsList) { %>
                                            <tr>
                                                <td class="fw-600 text-main"><%= trip.getId() %></td>
                                                <td class="fw-500"><%= trip.getDestination() %></td>
                                                <td class="text-muted"><%= trip.getDate() %></td>
                                                <td><span class="pax-badge"><i class="fas fa-users me-1"></i> <%= trip.getPassengers() %></span></td>
                                            </tr>
                                            <% } %>
                                        </tbody>
                                    </table>
                                </div>
                                <% } else { %>
                                <div class="empty-state">
                                    <div class="empty-icon light-green-bg"><i class="fas fa-clipboard"></i></div>
                                    <h3>No Trips Logged</h3>
                                    <p>Use the form to log your first assigned trip.</p>
                                </div>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </main>
    </div>

    <script src="${pageContext.request.contextPath}/js/driver-dashboard.js"></script>
</body>
</html>