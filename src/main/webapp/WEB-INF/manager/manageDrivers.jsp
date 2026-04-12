<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.transportmanager.model.Driver" %>
<%
    List<Driver> drivers = (List<Driver>) request.getAttribute("drivers");
    if (drivers == null) {
        drivers = java.util.Collections.emptyList();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Drivers - ATMS</title>
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
            <li class="menu-item"><a href="${pageContext.request.contextPath}/manager/trips/pending"><i class="fas fa-list-check"></i><span>Pending Queue</span></a></li>
            <li class="menu-item active"><a href="${pageContext.request.contextPath}/manager/drivers"><i class="fas fa-id-card"></i><span>Manage Drivers</span></a></li>
            <li class="menu-item"><a href="${pageContext.request.contextPath}/manager/reports/summary"><i class="fas fa-chart-line"></i><span>Reports</span></a></li>
        </ul>
        <div class="sidebar-footer"><a href="${pageContext.request.contextPath}/manager/logout" class="logout-btn"><i class="fas fa-sign-out-alt"></i><span>Logout</span></a></div>
    </aside>

    <main class="main-content">
        <header class="top-header">
            <div class="header-title">
                <h1>Approved Drivers Registry</h1>
                <p class="subtitle">Create and manage school-approved drivers for allocations</p>
            </div>
            <div class="profile-avatar"><i class="fas fa-id-card"></i></div>
        </header>

        <div class="dashboard-content">
            <% if (request.getParameter("error") != null) { %>
            <div class="error-alert"><i class="fas fa-exclamation-circle"></i>Error: <%= request.getParameter("error") %></div>
            <% } %>
            <% if (request.getParameter("success") != null) { %>
            <div class="error-alert" style="background:#dcfce7;border-left-color:#16a34a;color:#166534;"><i class="fas fa-check-circle"></i>Success: <%= request.getParameter("success") %></div>
            <% } %>

            <div class="content-split">
                <section class="card">
                    <div class="card-header"><h3><i class="fas fa-user-plus"></i>Add Approved Driver</h3></div>
                    <div class="card-body">
                        <form method="post" action="${pageContext.request.contextPath}/manager/drivers">
                            <div class="form-group"><label for="fullName">Full Name</label><input id="fullName" name="fullName" class="form-control" required></div>
                            <div class="form-group"><label for="email">Email</label><input id="email" name="email" type="email" class="form-control" required></div>
                            <div class="form-group"><label for="username">Username</label><input id="username" name="username" class="form-control" required></div>
                            <div class="form-group"><label for="licenseNumber">License Number</label><input id="licenseNumber" name="licenseNumber" class="form-control" required></div>
                            <div class="form-group"><label for="password">Temporary Password</label><input id="password" name="password" type="password" minlength="8" class="form-control" required></div>
                            <button class="btn btn-primary w-100" type="submit">Save Driver</button>
                        </form>
                    </div>
                </section>

                <section class="card">
                    <div class="card-header"><h3><i class="fas fa-users"></i>Current Drivers</h3></div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="data-table">
                                <thead><tr><th>ID</th><th>Name</th><th>License</th><th>Status</th></tr></thead>
                                <tbody>
                                <% if (drivers.isEmpty()) { %>
                                <tr><td colspan="4" class="text-muted">No drivers found.</td></tr>
                                <% } else { for (Driver d : drivers) { %>
                                <tr>
                                    <td class="fw-600"><%= d.getId() %></td>
                                    <td><%= d.getFullName() == null ? "-" : d.getFullName() %></td>
                                    <td><%= d.getLicenseNumber() == null ? "-" : d.getLicenseNumber() %></td>
                                    <td><span class="badge badge-status-approved"><%= d.getStatus() == null ? "AVAILABLE" : d.getStatus() %></span></td>
                                </tr>
                                <% }} %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </section>
            </div>
        </div>
    </main>
</div>
</body>
</html>
