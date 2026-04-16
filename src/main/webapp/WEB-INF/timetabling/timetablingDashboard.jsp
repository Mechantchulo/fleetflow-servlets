<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.timetabling.model.TimetableEntry" %>
<%@ page import="com.transportmanager.model.Trip" %>
<%
    List<TimetableEntry> entries = (List<TimetableEntry>) request.getAttribute("entries");
    if (entries == null) {
        entries = java.util.Collections.emptyList();
    }
    List<Trip> requestedTrips = (List<Trip>) request.getAttribute("requestedTrips");
    if (requestedTrips == null) {
        requestedTrips = java.util.Collections.emptyList();
    }
    Integer publishedCount = (Integer) request.getAttribute("publishedCount");
    Integer submittedCount = (Integer) request.getAttribute("submittedCount");
    Integer activeCount = (Integer) request.getAttribute("activeCount");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Timetabling Dashboard - ATMS</title>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff-dashboard.css">
</head>
<body>
<div class="app-container">
    <aside class="sidebar">
        <div class="sidebar-header">
            <div class="logo-icon"><i class="fas fa-bus"></i></div>
            <h2>ATMS</h2>
        </div>
        <ul class="sidebar-menu">
            <li class="menu-item active">
                <a href="${pageContext.request.contextPath}/timetabling/dashboard"><i class="fas fa-calendar-check"></i><span>Timetable Desk</span></a>
            </li>
        </ul>
        <div class="sidebar-footer">
            <a href="${pageContext.request.contextPath}/logout" class="logout-btn"><i class="fas fa-sign-out-alt"></i><span>Logout</span></a>
        </div>
    </aside>

    <main class="main-content">
        <header class="top-header">
            <div class="header-title">
                <h1>Timetabling Department</h1>
                <p class="subtitle">Receive staff requests (with optional PDFs), schedule dates, then submit source-of-truth entries to manager</p>
            </div>
            <div class="profile-avatar"><i class="fas fa-calendar-days"></i></div>
        </header>

        <div class="dashboard-content">
            <% if (request.getParameter("error") != null) { %>
            <div class="error-alert"><i class="fas fa-exclamation-circle"></i>Error: <%= request.getParameter("error") %></div>
            <% } %>
            <% if (request.getParameter("success") != null) { %>
            <div class="error-alert" style="background:#dcfce7;border-left-color:#16a34a;color:#166534;"><i class="fas fa-check-circle"></i>Success: <%= request.getParameter("success") %></div>
            <% } %>

            <section class="stats-grid">
                <div class="stat-card"><div class="stat-icon pending-bg"><i class="fas fa-file-circle-plus"></i></div><div class="stat-details"><h3><%= publishedCount == null ? 0 : publishedCount %></h3><p>Ready to Submit</p></div></div>
                <div class="stat-card"><div class="stat-icon info-bg"><i class="fas fa-paper-plane"></i></div><div class="stat-details"><h3><%= submittedCount == null ? 0 : submittedCount %></h3><p>Submitted to Manager</p></div></div>
                <div class="stat-card"><div class="stat-icon success-bg"><i class="fas fa-circle-check"></i></div><div class="stat-details"><h3><%= activeCount == null ? 0 : activeCount %></h3><p>Activated by Manager</p></div></div>
                <div class="stat-card"><div class="stat-icon secondary-bg"><i class="fas fa-inbox"></i></div><div class="stat-details"><h3><%= requestedTrips.size() %></h3><p>Staff Needs Waiting</p></div></div>
            </section>

            <div class="filter-actions" style="justify-content:flex-end;margin-bottom:16px;">
                <form method="post" action="${pageContext.request.contextPath}/timetabling/dashboard" style="display:inline;">
                    <input type="hidden" name="action" value="submitToManager">
                    <button class="btn btn-primary" type="submit">Submit All to Manager</button>
                </form>
                <a class="btn btn-outline" href="${pageContext.request.contextPath}/timetabling/export/pdf">Export PDF</a>
            </div>

            <div class="content-split">
                <section class="card">
                    <div class="card-header"><h3><i class="fas fa-plus-circle"></i>Create Timetable Entry</h3></div>
                    <div class="card-body">
                        <form method="post" action="${pageContext.request.contextPath}/timetabling/dashboard">
                            <div class="form-group">
                                <label for="title">Entry Title</label>
                                <input type="text" id="title" name="title" class="form-control" placeholder="e.g. Academic Field Trip - Year 2" required>
                            </div>
                            <div class="form-group">
                                <label for="department">Department</label>
                                <input type="text" id="department" name="department" class="form-control" pattern="[A-Za-z ]+" title="Use letters and spaces only" placeholder="e.g. School of Engineering">
                            </div>
                            <div class="form-group">
                                <label for="destination">Destination</label>
                                <input type="text" id="destination" name="destination" class="form-control" placeholder="Destination" required>
                            </div>
                            <div class="form-group">
                                <label for="departureTime">Departure Time</label>
                                <input type="datetime-local" id="departureTime" name="departureTime" class="form-control" required>
                            </div>
                            <div class="form-group">
                                <label for="expectedPassengerCount">Expected Passengers</label>
                                <input type="number" id="expectedPassengerCount" name="expectedPassengerCount" min="0" value="0" class="form-control">
                            </div>
                            <div class="form-group">
                                <label for="budgetAmount">Budget (KES)</label>
                                <input type="number" step="0.01" id="budgetAmount" name="budgetAmount" min="0" value="0" class="form-control">
                            </div>
                            <button class="btn btn-primary w-100" type="submit">Publish Entry</button>
                        </form>
                    </div>
                </section>

                <section class="card">
                    <div class="card-header"><h3><i class="fas fa-list"></i>Upcoming Timetable Entries</h3></div>
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
                                    <th>Created By</th>
                                </tr>
                                </thead>
                                <tbody>
                                <% if (entries.isEmpty()) { %>
                                <tr><td colspan="9" class="text-muted">No timetable entries have been published yet.</td></tr>
                                <% } else {
                                    for (TimetableEntry entry : entries) {
                                        String status = entry.getStatus() == null ? "PUBLISHED" : entry.getStatus();
                                        String statusClass = "badge-status-approved";
                                        if ("SUBMITTED".equalsIgnoreCase(status)) {
                                            statusClass = "badge-status-pending";
                                        } else if ("ACTIVE".equalsIgnoreCase(status)) {
                                            statusClass = "badge-status-assigned";
                                        }
                                %>
                                <tr>
                                    <td class="fw-600"><%= entry.getId() %></td>
                                    <td><%= entry.getTitle() %></td>
                                    <td><%= entry.getDepartment() == null ? "-" : entry.getDepartment() %></td>
                                    <td><%= entry.getDestination() %></td>
                                    <td><%= entry.getDepartureTime() == null ? "-" : entry.getDepartureTime() %></td>
                                    <td><%= entry.getExpectedPassengerCount() %></td>
                                    <td><%= entry.getBudgetAmount() == null ? "0.00" : entry.getBudgetAmount() %></td>
                                    <td><span class="badge <%= statusClass %>"><%= status %></span></td>
                                    <td><%= entry.getCreatedByName() == null ? "-" : entry.getCreatedByName() %></td>
                                </tr>
                                <% }
                                } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </section>
            </div>

            <section class="card" style="margin-top:24px;">
                <div class="card-header"><h3><i class="fas fa-list-check"></i>Schedule Staff Requests Into Timetable</h3></div>
                <div class="card-body">
                    <% if (requestedTrips.isEmpty()) { %>
                        <p class="text-muted">No pending staff requests in <strong>REQUESTED</strong> state.</p>
                    <% } else { %>
                        <div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(280px,1fr));gap:14px;">
                            <% for (Trip req : requestedTrips) { %>
                            <div class="card">
                                <div class="card-body">
                                    <p style="margin:0 0 6px;"><strong>Request <%= req.getId() %></strong></p>
                                    <p style="margin:0 0 4px;"><strong><%= req.getRequesterName() == null ? "Staff" : req.getRequesterName() %></strong></p>
                                    <p style="margin:0 0 4px;"><%= req.getDepartment() == null ? "No Department" : req.getDepartment() %></p>
                                    <p style="margin:0 0 4px;">Destination: <strong><%= req.getDestination() == null ? "-" : req.getDestination() %></strong></p>
                                    <p style="margin:0 0 4px;">Requested Date: <strong><%= req.getDepartureDate() == null ? "-" : req.getDepartureDate() %></strong></p>
                                    <p style="margin:0 0 10px;">Passengers: <strong><%= req.getPassengerCount() %></strong> • Budget: <strong>KES <%= req.getRequestedBudget() == null ? "0.00" : req.getRequestedBudget() %></strong></p>
                                    <div class="filter-actions">
                                        <% if (req.isHasSchedulingDocument()) { %>
                                            <a class="btn btn-outline" href="${pageContext.request.contextPath}/staff/requests/document?id=<%= req.getId() %>">PDF</a>
                                        <% } %>
                                        <a class="btn btn-primary" href="${pageContext.request.contextPath}/timetabling/requests/schedule?id=<%= req.getId() %>">Schedule</a>
                                    </div>
                                </div>
                            </div>
                            <% } %>
                        </div>
                    <% } %>
                </div>
            </section>
        </div>
    </main>
</div>
</body>
</html>
