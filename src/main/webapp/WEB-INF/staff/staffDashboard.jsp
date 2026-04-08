<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.staff.model.Request" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Staff Dashboard - FleetFlow</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff-dashboard.css">
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
                    <a href="${pageContext.request.contextPath}/staff/dashboard">
                        <i class="fas fa-home"></i>
                        <span>My Dashboard</span>
                    </a>
                </li>
                <li class="menu-item">
                    <a href="#new-request">
                        <i class="fas fa-plus-circle"></i>
                        <span>New Request</span>
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
                    <h1>Staff Portal</h1>
                    <p class="subtitle">Welcome back, ${username != null ? username : 'Staff Member'}</p>
                </div>
                <div class="header-profile">
                    <div class="profile-avatar">
                        <i class="fas fa-user"></i>
                    </div>
                </div>
            </header>

            <div class="dashboard-content">
                
                <section class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-icon secondary-bg"><i class="fas fa-folder-open"></i></div>
                        <div class="stat-details">
                            <h3>${totalRequests}</h3>
                            <p>Total Requests</p>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon light-green-bg"><i class="fas fa-clock"></i></div>
                        <div class="stat-details">
                            <h3>${pendingRequests}</h3>
                            <p>Pending Approval</p>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon success-bg"><i class="fas fa-check-circle"></i></div>
                        <div class="stat-details">
                            <h3>${approvedRequests}</h3>
                            <p>Approved Trips</p>
                        </div>
                    </div>
                </section>

                <div class="content-split">
                    <div class="form-section" id="new-request">
                        <div class="card form-card">
                            <div class="card-header">
                                <h3><i class="fas fa-paper-plane"></i> Request a Vehicle</h3>
                            </div>
                            <div class="card-body">
                                <form method="post" action="${pageContext.request.contextPath}/staff/dashboard" id="requestForm">
                                    <div class="form-group">
                                        <label for="destination">Destination</label>
                                        <input type="text" name="destination" id="destination" class="form-control" placeholder="e.g., Main Campus" required>
                                    </div>
                                    
                                    <div class="form-group">
                                        <label for="date">Departure Date</label>
                                        <input type="date" name="date" id="date" class="form-control" required>
                                    </div>

                                    <div class="form-group">
                                        <label for="passengers">Number of Passengers</label>
                                        <input type="number" name="passengers" id="passengers" class="form-control" min="1" max="100" placeholder="e.g., 15" required>
                                    </div>

                                    <div class="form-group">
                                        <label for="purpose">Purpose of Trip</label>
                                        <textarea name="purpose" id="purpose" class="form-control" rows="3" placeholder="Briefly describe the reason for this trip..."></textarea>
                                    </div>

                                    <button type="submit" class="btn btn-primary w-100 mt-3">
                                        Submit Request
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>

                    <div class="history-section">
                        <div class="card table-card">
                            <div class="card-header d-flex-between">
                                <h3><i class="fas fa-history"></i> My Request History</h3>
                            </div>
                            <div class="card-body p-0">
                                <% 
                                List<Request> requestsList = (List<Request>) request.getAttribute("requests");
                                if (requestsList != null && !requestsList.isEmpty()) {
                                %>
                                <div class="table-responsive">
                                    <table class="data-table">
                                        <thead>
                                            <tr>
                                                <th>ID</th>
                                                <th>Destination</th>
                                                <th>Date</th>
                                                <th>Status</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <% for (Request req : requestsList) { %>
                                            <tr>
                                                <td class="fw-600 text-muted">REQ-${req.getId()}</td>
                                                <td class="fw-500">${req.getDestination()}</td>
                                                <td>${req.getDate()}</td>
                                                <td>
                                                    <span class="badge badge-status-${req.getStatus().toLowerCase()}">
                                                        ${req.getStatus()}
                                                    </span>
                                                </td>
                                            </tr>
                                            <% } %>
                                        </tbody>
                                    </table>
                                </div>
                                <% } else { %>
                                <div class="empty-state">
                                    <div class="empty-icon secondary-bg"><i class="fas fa-inbox"></i></div>
                                    <h3>No Requests Yet</h3>
                                    <p>Fill out the form to request your first trip.</p>
                                </div>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </main>
    </div>

    <script src="${pageContext.request.contextPath}/js/staff-dashboard.js"></script>
</body>
</html>