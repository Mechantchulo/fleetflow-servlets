<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manager Overview - FleetFlow</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/manager-dashboard.css">
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
                    <a href="${pageContext.request.contextPath}/manager/dashboard">
                        <i class="fas fa-chart-pie"></i>
                        <span>Overview</span>
                    </a>
                </li>
                <li class="menu-item">
                    <a href="${pageContext.request.contextPath}/manager/trips/pending">
                        <i class="fas fa-list-ul"></i>
                        <span>Pending Trips</span>
                    </a>
                </li>
                <li class="menu-item">
                    <a href="#">
                        <i class="fas fa-bus-alt"></i>
                        <span>Fleet Status</span>
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
                    <h1>Transport Manager Dashboard</h1>
                    <p class="subtitle">Command Center - ${sessionScope.managerUsername != null ? sessionScope.managerUsername : 'Manager'}</p>
                </div>
                <div class="header-profile">
                    <div class="profile-avatar"><i class="fas fa-user-cog"></i></div>
                </div>
            </header>

            <div class="dashboard-content">

                <% if (request.getAttribute("highPriorityCount") != null && (Integer)request.getAttribute("highPriorityCount") > 0) { %>
                <div class="urgent-alert">
                    <div class="urgent-text">
                        <i class="fas fa-exclamation-triangle"></i>
                        <span>You have ${highPriorityCount} HIGH priority trips awaiting allocation.</span>
                    </div>
                    <a href="${pageContext.request.contextPath}/manager/trips/pending?priority=HIGH" class="btn btn-danger">Review Now</a>
                </div>
                <% } %>
                
                <section class="overview-grid">
                    <div class="stat-card">
                        <div class="stat-icon light-green-bg"><i class="fas fa-clipboard-list"></i></div>
                        <div class="stat-details">
                            <h3>${pendingCount != null ? pendingCount : 0}</h3>
                            <p>Pending Requests</p>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon success-bg"><i class="fas fa-bus"></i></div>
                        <div class="stat-details">
                            <h3>${availableBuses != null ? availableBuses : 0}</h3>
                            <p>Buses Available</p>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon success-bg"><i class="fas fa-id-card"></i></div>
                        <div class="stat-details">
                            <h3>${availableDrivers != null ? availableDrivers : 0}</h3>
                            <p>Drivers Available</p>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon info-bg"><i class="fas fa-route"></i></div>
                        <div class="stat-details">
                            <h3>${tripsToday != null ? tripsToday : 0}</h3>
                            <p>Active Trips Today</p>
                        </div>
                    </div>
                </section>

                <div class="section-header">
                    <h2>Quick Actions</h2>
                </div>
                <section class="action-cards">
                    <a href="${pageContext.request.contextPath}/manager/trips/pending" class="action-card">
                        <div class="action-icon light-green-bg"><i class="fas fa-tasks"></i></div>
                        <h3>Process Queue</h3>
                        <p>Review and allocate resources to staff requests.</p>
                    </a>
                    
                    <a href="#" class="action-card">
                        <div class="action-icon info-bg"><i class="fas fa-bus-alt"></i></div>
                        <h3>Manage Fleet</h3>
                        <p>View bus status, maintenance, and capacities.</p>
                    </a>

                    <a href="#" class="action-card">
                        <div class="action-icon pending-bg"><i class="fas fa-users"></i></div>
                        <h3>Manage Drivers</h3>
                        <p>View driver availability and current assignments.</p>
                    </a>
                </section>

            </div>
        </main>
    </div>

    <script src="${pageContext.request.contextPath}/js/manager-dashboard.js"></script>
</body>
</html>