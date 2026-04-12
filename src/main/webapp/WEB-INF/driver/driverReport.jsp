<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.Map" %>
<%
    Map<String, Object> summary = (Map<String, Object>) request.getAttribute("reportSummary");
    if (summary == null) {
        summary = java.util.Collections.emptyMap();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Driver Report - ATMS</title>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/driver-dashboard.css">
</head>
<body>
<div class="app-container">
    <aside class="sidebar">
        <div class="sidebar-header">
            <div class="logo-icon"><i class="fas fa-bus"></i></div>
            <h2>ATMS</h2>
        </div>

        <ul class="sidebar-menu">
            <li class="menu-item"><a href="${pageContext.request.contextPath}/driver/dashboard"><i class="fas fa-steering-wheel"></i><span>Dashboard</span></a></li>
            <li class="menu-item active"><a href="${pageContext.request.contextPath}/driver/reports/summary"><i class="fas fa-chart-column"></i><span>My Report</span></a></li>
        </ul>

        <div class="sidebar-footer">
            <a href="${pageContext.request.contextPath}/logout" class="logout-btn"><i class="fas fa-sign-out-alt"></i><span>Logout</span></a>
        </div>
    </aside>

    <main class="main-content">
        <header class="top-header">
            <div class="header-title">
                <h1>Driver Performance Report</h1>
                <p class="subtitle">Assigned-trip summary for the selected period</p>
            </div>
            <div class="profile-avatar"><i class="fas fa-id-badge"></i></div>
        </header>

        <div class="dashboard-content">
            <div class="filter-actions" style="justify-content:flex-end;margin-bottom:16px;">
                <a class="btn btn-outline" href="${pageContext.request.contextPath}/driver/reports/pdf?startDate=${reportStartDate}&endDate=${reportEndDate}">Export PDF</a>
            </div>
            <section class="card" style="margin-bottom:24px;">
                <div class="card-header"><h3><i class="fas fa-calendar"></i>Report Date Range</h3></div>
                <div class="card-body">
                    <form method="get" action="${pageContext.request.contextPath}/driver/reports/summary" class="filter-form" style="padding:0;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));">
                        <div class="form-group">
                            <label for="startDate">Start Date</label>
                            <input id="startDate" type="date" class="form-control" name="startDate" value="${reportStartDate}">
                        </div>
                        <div class="form-group">
                            <label for="endDate">End Date</label>
                            <input id="endDate" type="date" class="form-control" name="endDate" value="${reportEndDate}">
                        </div>
                        <div class="filter-actions">
                            <button type="submit" class="btn btn-primary">Apply Range</button>
                            <a class="btn btn-outline" href="${pageContext.request.contextPath}/driver/reports/summary">Reset</a>
                        </div>
                    </form>
                </div>
            </section>

            <section class="stats-grid">
                <div class="stat-card"><div class="stat-icon info-bg"><i class="fas fa-route"></i></div><div class="stat-details"><h3><%= summary.getOrDefault("totalAssignedTrips", 0) %></h3><p>Total Assigned Trips</p></div></div>
                <div class="stat-card"><div class="stat-icon success-bg"><i class="fas fa-truck-fast"></i></div><div class="stat-details"><h3><%= summary.getOrDefault("activeAssignments", 0) %></h3><p>Active Assignments</p></div></div>
                <div class="stat-card"><div class="stat-icon pending-bg"><i class="fas fa-shield"></i></div><div class="stat-details"><h3><%= summary.getOrDefault("overriddenAssignments", 0) %></h3><p>Override Assignments</p></div></div>
                <div class="stat-card"><div class="stat-icon light-green-bg"><i class="fas fa-users"></i></div><div class="stat-details"><h3><%= summary.getOrDefault("passengersHandled", 0) %></h3><p>Passengers Handled</p></div></div>
            </section>

            <section class="card">
                <div class="card-header"><h3><i class="fas fa-clipboard-check"></i>Scope</h3></div>
                <div class="card-body">
                    <p class="text-muted">Report period: <strong>${reportStartDate}</strong> to <strong>${reportEndDate}</strong></p>
                    <p class="text-muted">Data scope: <strong><%= summary.getOrDefault("driverScope", "CURRENT_DRIVER") %></strong></p>
                </div>
            </section>
        </div>
    </main>
</div>
</body>
</html>
