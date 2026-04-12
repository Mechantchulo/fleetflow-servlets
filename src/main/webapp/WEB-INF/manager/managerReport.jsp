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
    <title>Manager Report - ATMS</title>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/manager-dashboard.css">
</head>
<body>
<div class="app-container">
    <aside class="sidebar">
        <div class="sidebar-header">
            <div class="logo-icon"><i class="fas fa-bus"></i></div>
            <h2>ATMS</h2>
        </div>
        <ul class="sidebar-menu">
            <li class="menu-item"><a href="${pageContext.request.contextPath}/manager/dashboard"><i class="fas fa-chart-pie"></i><span>Overview</span></a></li>
            <li class="menu-item"><a href="${pageContext.request.contextPath}/manager/trips/pending"><i class="fas fa-list-check"></i><span>Pending Queue</span></a></li>
            <li class="menu-item"><a href="${pageContext.request.contextPath}/manager/drivers"><i class="fas fa-id-card"></i><span>Manage Drivers</span></a></li>
            <li class="menu-item">
                <a href="${pageContext.request.contextPath}/manager/timetables/submitted"><i class="fas fa-calendar-check"></i><span>Submitted Timetables</span></a></li>
            <li class="menu-item active"><a href="${pageContext.request.contextPath}/manager/reports/summary"><i class="fas fa-chart-line"></i><span>Reports</span></a></li>
        </ul>
        <div class="sidebar-footer">
            <a href="${pageContext.request.contextPath}/manager/logout" class="logout-btn"><i class="fas fa-sign-out-alt"></i><span>Logout</span></a>
        </div>
    </aside>

    <main class="main-content">
        <header class="top-header">
            <div class="header-title">
                <h1>Manager Reports</h1>
                <p class="subtitle">Monthly default view with custom date range support</p>
            </div>
            <div class="profile-avatar"><i class="fas fa-file-chart-column"></i></div>
        </header>

        <div class="dashboard-content">
            <div class="filter-actions" style="justify-content:flex-end;margin-bottom:16px;">
                <a class="btn btn-outline" href="${pageContext.request.contextPath}/manager/reports/pdf?startDate=${reportStartDate}&endDate=${reportEndDate}">Export PDF</a>
            </div>
            <section class="card" style="margin-bottom:24px;">
                <div class="card-header"><h3><i class="fas fa-calendar"></i>Report Range</h3></div>
                <div class="card-body">
                    <form method="get" action="${pageContext.request.contextPath}/manager/reports/summary" class="filter-form" style="padding:0;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));">
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
                            <a class="btn btn-outline" href="${pageContext.request.contextPath}/manager/reports/summary">Reset</a>
                        </div>
                    </form>
                </div>
            </section>

            <section class="stats-grid">
                <div class="stat-card"><div class="stat-icon info-bg"><i class="fas fa-clipboard-list"></i></div><div class="stat-details"><h3><%= summary.getOrDefault("totalRequests", 0) %></h3><p>Total Requests</p></div></div>
                <div class="stat-card"><div class="stat-icon success-bg"><i class="fas fa-check-circle"></i></div><div class="stat-details"><h3><%= summary.getOrDefault("assignedRequests", 0) %></h3><p>Assigned Requests</p></div></div>
                <div class="stat-card"><div class="stat-icon pending-bg"><i class="fas fa-hourglass-half"></i></div><div class="stat-details"><h3><%= summary.getOrDefault("openRequests", 0) %></h3><p>Open Requests</p></div></div>
                <div class="stat-card"><div class="stat-icon danger-bg"><i class="fas fa-ban"></i></div><div class="stat-details"><h3><%= summary.getOrDefault("rejectedRequests", 0) %></h3><p>Rejected</p></div></div>
            </section>

            <section class="card">
                <div class="card-header"><h3><i class="fas fa-table"></i>Operational Metrics</h3></div>
                <div class="card-body p-0">
                    <table class="data-table">
                        <thead>
                        <tr><th>Metric</th><th>Value</th></tr>
                        </thead>
                        <tbody>
                        <tr><td>Total Passengers</td><td class="fw-600"><%= summary.getOrDefault("totalPassengers", 0) %></td></tr>
                        <tr><td>Total Allocations</td><td class="fw-600"><%= summary.getOrDefault("totalAllocations", 0) %></td></tr>
                        <tr><td>Soft Overrides Used</td><td class="fw-600"><%= summary.getOrDefault("overrideAllocations", 0) %></td></tr>
                        <tr><td>Report Period</td><td class="fw-600">${reportStartDate} to ${reportEndDate}</td></tr>
                        </tbody>
                    </table>
                </div>
            </section>
        </div>
    </main>
</div>
</body>
</html>
