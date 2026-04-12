<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.timetabling.model.TimetableEntry" %>
<%
    List<TimetableEntry> entries = (List<TimetableEntry>) request.getAttribute("submittedEntries");
    if (entries == null) {
        entries = java.util.Collections.emptyList();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Submitted Timetables - ATMS</title>
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
            <li class="menu-item active"><a href="${pageContext.request.contextPath}/manager/timetables/submitted"><i class="fas fa-calendar-check"></i><span>Submitted Timetables</span></a></li>
            <li class="menu-item"><a href="${pageContext.request.contextPath}/manager/reports/summary"><i class="fas fa-chart-line"></i><span>Reports</span></a></li>
        </ul>
        <div class="sidebar-footer"><a href="${pageContext.request.contextPath}/manager/logout" class="logout-btn"><i class="fas fa-sign-out-alt"></i><span>Logout</span></a></div>
    </aside>

    <main class="main-content">
        <header class="top-header">
            <div class="header-title">
                <h1>Submitted Timetable Trips</h1>
                <p class="subtitle">Source-of-truth trips from timetabling, with budgets, ready for manager activation</p>
            </div>
            <div class="profile-avatar"><i class="fas fa-calendar-day"></i></div>
        </header>

        <div class="dashboard-content">
            <% if (request.getParameter("error") != null) { %>
                <div class="error-alert"><i class="fas fa-exclamation-circle"></i>Error: <%= request.getParameter("error") %></div>
            <% } %>
            <% if (request.getParameter("success") != null) { %>
                <div class="error-alert" style="background:#dcfce7;border-left-color:#16a34a;color:#166534;"><i class="fas fa-check-circle"></i>Success: <%= request.getParameter("success") %></div>
            <% } %>

            <div class="filter-actions" style="justify-content:flex-end;margin-bottom:14px;">
                <a class="btn btn-outline" href="${pageContext.request.contextPath}/manager/timetables/export/pdf?scope=submitted">Export Submitted PDF</a>
            </div>

            <section class="card">
                <div class="card-header"><h3><i class="fas fa-table"></i>Timetable Submission Queue</h3></div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Title</th>
                                    <th>Department</th>
                                    <th>Destination</th>
                                    <th>Departure</th>
                                    <th>Pax</th>
                                    <th>Budget (KES)</th>
                                    <th>Status</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                            <% if (entries.isEmpty()) { %>
                                <tr><td colspan="9" class="text-muted">No submitted timetable entries found.</td></tr>
                            <% } else {
                                for (TimetableEntry entry : entries) {
                                    String status = entry.getStatus() == null ? "SUBMITTED" : entry.getStatus();
                            %>
                                <tr>
                                    <td class="fw-600"><%= entry.getId() %></td>
                                    <td><%= entry.getTitle() == null ? "-" : entry.getTitle() %></td>
                                    <td><%= entry.getDepartment() == null ? "-" : entry.getDepartment() %></td>
                                    <td><%= entry.getDestination() == null ? "-" : entry.getDestination() %></td>
                                    <td><%= entry.getDepartureTime() == null ? "-" : entry.getDepartureTime() %></td>
                                    <td><%= entry.getExpectedPassengerCount() %></td>
                                    <td><%= entry.getBudgetAmount() == null ? "0.00" : entry.getBudgetAmount() %></td>
                                    <td><span class="badge badge-status-pending"><%= status %></span></td>
                                    <td>
                                        <form method="post" action="${pageContext.request.contextPath}/manager/timetables/submitted">
                                            <input type="hidden" name="entryId" value="<%= entry.getId() %>">
                                            <button class="btn btn-primary" type="submit">Activate</button>
                                        </form>
                                    </td>
                                </tr>
                            <% }
                            } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </section>
        </div>
    </main>
</div>
</body>
</html>
