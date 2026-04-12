<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.driver.driverdashboard.Trip" %>
<%@ page import="com.driver.driverdashboard.DriverTripLog" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Driver Dashboard - ATMS</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
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
                <li class="menu-item active">
                    <a href="${pageContext.request.contextPath}/driver/dashboard">
                        <i class="fas fa-steering-wheel"></i>
                        <span>My Dashboard</span>
                    </a>
                </li>
                <li class="menu-item">
                    <a href="${pageContext.request.contextPath}/driver/reports/summary">
                        <i class="fas fa-chart-column"></i>
                        <span>My Report</span>
                    </a>
                </li>
            </ul>

            <div class="sidebar-footer">
                <a href="${pageContext.request.contextPath}/logout" class="logout-btn">
                    <i class="fas fa-sign-out-alt"></i>
                    <span>Logout</span>
                </a>
            </div>
        </aside>

        <main class="main-content">
            <header class="top-header">
                <div class="header-title">
                    <h1>Driver Portal</h1>
                    <p class="subtitle">Assigned trips and daily dispatch details</p>
                </div>
                <div class="header-profile">
                    <div class="profile-avatar">
                        <i class="fas fa-id-badge"></i>
                    </div>
                </div>
            </header>

            <div class="dashboard-content">
                <div class="filter-actions" style="justify-content:flex-end;margin-bottom:16px;">
                    <a class="btn btn-outline" href="${pageContext.request.contextPath}/driver/reports/pdf">Export Driver PDF</a>
                </div>

                <% if (session.getAttribute("error") != null) { %>
                <div class="error-alert">
                    <i class="fas fa-exclamation-circle"></i> <%= session.getAttribute("error") %>
                </div>
                <% session.removeAttribute("error"); } %>

                <div class="content-split" style="margin-bottom:20px;">
                    <div class="card form-card">
                        <div class="card-header">
                            <h3><i class="fas fa-pen-to-square"></i> Trip Log & Incident Report</h3>
                        </div>
                        <div class="card-body">
                            <form method="post" action="${pageContext.request.contextPath}/driver/dashboard">
                                <div class="form-group">
                                    <label for="tripRequestId">Assigned Trip</label>
                                    <select id="tripRequestId" name="tripRequestId" class="form-control" required>
                                        <option value="">Select trip</option>
                                        <% 
                                            List<Trip> formTripsList = (List<Trip>) request.getAttribute("trips");
                                            if (formTripsList != null) {
                                                for (Trip trip : formTripsList) {
                                        %>
                                        <option value="<%= trip.getId() %>">
                                            Trip <%= trip.getId() %> - <%= trip.getDestination() %> (<%= trip.getDate() %>)
                                        </option>
                                        <%      }
                                            } %>
                                    </select>
                                </div>

                                <div class="form-group">
                                    <label for="reportType">Report Type</label>
                                    <select id="reportType" name="reportType" class="form-control">
                                        <option value="OTHER">Other</option>
                                        <option value="INCIDENT">Incident</option>
                                        <option value="MECHANICAL">Mechanical Issue</option>
                                        <option value="FUEL">Fuel / Refill</option>
                                        <option value="DELAY">Delay</option>
                                    </select>
                                </div>

                                <div class="form-group">
                                    <label for="startTime">Trip Start Time</label>
                                    <input type="datetime-local" id="startTime" name="startTime" class="form-control">
                                </div>

                                <div class="form-group">
                                    <label for="endTime">Trip End Time</label>
                                    <input type="datetime-local" id="endTime" name="endTime" class="form-control">
                                </div>

                                <div class="form-group">
                                    <label for="reportNotes">Notes / Incident Details</label>
                                    <textarea id="reportNotes" name="reportNotes" class="form-control" rows="4" placeholder="Add trip summary, issues, incident details, or any other report..."></textarea>
                                </div>

                                <button type="submit" class="btn btn-primary w-100">Save Driver Log</button>
                            </form>
                        </div>
                    </div>

                    <div class="card table-card">
                        <div class="card-header d-flex-between">
                            <h3><i class="fas fa-list-check"></i> Recent Driver Logs</h3>
                        </div>
                        <div class="card-body p-0">
                            <%
                                List<DriverTripLog> logs = (List<DriverTripLog>) request.getAttribute("logs");
                                if (logs != null && !logs.isEmpty()) {
                            %>
                            <div class="table-responsive">
                                <table class="data-table">
                                    <thead>
                                    <tr>
                                        <th>Trip</th>
                                        <th>Type</th>
                                        <th>Start</th>
                                        <th>End</th>
                                        <th>Notes</th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <% for (DriverTripLog log : logs) { %>
                                    <tr>
                                        <td class="fw-600">
                                            <%= log.getTripRequestId() %><br>
                                            <span class="text-muted"><%= log.getDestination() == null ? "-" : log.getDestination() %></span>
                                        </td>
                                        <td><span class="badge badge-status-pending"><%= log.getReportType() == null ? "OTHER" : log.getReportType() %></span></td>
                                        <td class="text-muted"><%= log.getStartTime() == null ? "-" : log.getStartTime() %></td>
                                        <td class="text-muted"><%= log.getEndTime() == null ? "-" : log.getEndTime() %></td>
                                        <td><%= log.getReportNotes() == null || log.getReportNotes().isBlank() ? "-" : log.getReportNotes() %></td>
                                    </tr>
                                    <% } %>
                                    </tbody>
                                </table>
                            </div>
                            <% } else { %>
                            <div class="empty-state">
                                <div class="empty-icon light-green-bg"><i class="fas fa-note-sticky"></i></div>
                                <h3>No Driver Logs Yet</h3>
                                <p>Submit start/end time or incident notes to create your first log.</p>
                            </div>
                            <% } %>
                        </div>
                    </div>
                </div>

                <div class="card table-card">
                    <div class="card-header d-flex-between">
                        <h3><i class="fas fa-history"></i> Assigned Trips</h3>
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
                            <h3>No Assigned Trips</h3>
                            <p>Assignments from the manager will appear here.</p>
                        </div>
                        <% } %>
                    </div>
                </div>

            </div>
        </main>
    </div>

    <script src="${pageContext.request.contextPath}/js/driver-dashboard.js"></script>
</body>
</html>
