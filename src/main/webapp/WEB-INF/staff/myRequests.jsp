<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.staff.model.Request" %>
<%
    String activeTab = (String) request.getAttribute("activeTab");
    String search = (String) request.getAttribute("search");
    if (activeTab == null) {
        activeTab = "all";
    }
    if (search == null) {
        search = "";
    }
    List<Request> requestsList = (List<Request>) request.getAttribute("requests");
    if (requestsList == null) {
        requestsList = java.util.Collections.emptyList();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Requests - ATMS</title>
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
            <li class="menu-item"><a href="${pageContext.request.contextPath}/staff/dashboard"><i class="fas fa-house"></i><span>Dashboard</span></a></li>
            <li class="menu-item active"><a href="${pageContext.request.contextPath}/staff/myRequests"><i class="fas fa-clipboard-list"></i><span>My Requests</span></a></li>
            <li class="menu-item"><a href="${pageContext.request.contextPath}/staff/trip-history"><i class="fas fa-clock-rotate-left"></i><span>Trip History</span></a></li>
        </ul>

        <div class="sidebar-footer">
            <a href="${pageContext.request.contextPath}/logout" class="logout-btn"><i class="fas fa-sign-out-alt"></i><span>Logout</span></a>
        </div>
    </aside>

    <main class="main-content">
        <header class="top-header">
            <div class="header-title">
                <h1>My Requests</h1>
                <p class="subtitle">Track request status and search by ID, driver, or destination</p>
            </div>
            <div class="profile-avatar"><i class="fas fa-user"></i></div>
        </header>

        <div class="dashboard-content">
            <div class="filter-actions" style="justify-content:flex-end;margin-bottom:16px;">
                <a class="btn btn-outline" href="${pageContext.request.contextPath}/staff/reports/pdf">Export Requests PDF</a>
            </div>
            <section class="action-cards" style="margin-bottom: 20px;">
                <a class="action-card <%= "all".equalsIgnoreCase(activeTab) ? "" : "" %>" href="${pageContext.request.contextPath}/staff/myRequests?tab=all">
                    <div class="action-icon secondary-bg"><i class="fas fa-layer-group"></i></div>
                    <h3>All</h3>
                    <p>View all requests.</p>
                </a>
                <a class="action-card" href="${pageContext.request.contextPath}/staff/myRequests?tab=pending">
                    <div class="action-icon pending-bg"><i class="fas fa-hourglass-half"></i></div>
                    <h3>Pending (${pendingCount})</h3>
                    <p>Awaiting manager action.</p>
                </a>
                <a class="action-card" href="${pageContext.request.contextPath}/staff/myRequests?tab=approved">
                    <div class="action-icon success-bg"><i class="fas fa-check-circle"></i></div>
                    <h3>Approved (${approvedCount})</h3>
                    <p>Approved/confirmed requests.</p>
                </a>
                <a class="action-card" href="${pageContext.request.contextPath}/staff/myRequests?tab=rejected">
                    <div class="action-icon danger-bg"><i class="fas fa-xmark-circle"></i></div>
                    <h3>Rejected (${rejectedCount})</h3>
                    <p>Rejected requests.</p>
                </a>
            </section>

            <section class="card" style="margin-bottom: 24px;">
                <div class="card-header"><h3><i class="fas fa-magnifying-glass"></i>Search</h3></div>
                <div class="card-body">
                    <form class="filter-form" style="padding: 0;" method="get" action="${pageContext.request.contextPath}/staff/myRequests">
                        <input type="hidden" name="tab" value="<%= activeTab %>">
                        <div class="form-group">
                            <label for="search">Search Query</label>
                            <input id="search" class="form-control" type="search" name="search" value="<%= search %>" placeholder="Request ID, driver, or destination">
                        </div>
                        <div class="filter-actions">
                            <button class="btn btn-primary" type="submit">Search</button>
                            <a class="btn btn-outline" href="${pageContext.request.contextPath}/staff/myRequests">Reset</a>
                        </div>
                    </form>
                </div>
            </section>

            <section class="card">
                <div class="card-header"><h3><i class="fas fa-table"></i>Request Results</h3></div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="data-table">
                            <thead>
                            <tr>
                                <th>ID</th>
                                <th>Date</th>
                                <th>Driver</th>
                                <th>Initials</th>
                                <th>Destination</th>
                                <th>Department</th>
                                <th>Status</th>
                            </tr>
                            </thead>
                            <tbody>
                            <% if (requestsList.isEmpty()) { %>
                            <tr><td colspan="7" class="text-muted">No requests matched the current filters.</td></tr>
                            <% } else {
                                for (Request item : requestsList) {
                                    String status = item.getStatus() == null ? "Pending" : item.getStatus();
                                    String statusClass;
                                    if ("Approved".equalsIgnoreCase(status) || "Confirmed".equalsIgnoreCase(status)) {
                                        statusClass = "approved";
                                    } else if ("Rejected".equalsIgnoreCase(status)) {
                                        statusClass = "rejected";
                                    } else {
                                        statusClass = "pending";
                                    }
                            %>
                            <tr>
                                <td class="fw-600"><%= item.getId() %></td>
                                <td><%= item.getDate() %></td>
                                <td><%= item.getDriver() %></td>
                                <td><%= item.getDriverInitials() %></td>
                                <td><%= item.getDestination() %></td>
                                <td><%= item.getDepartment() == null ? "-" : item.getDepartment() %></td>
                                <td><span class="badge badge-status-<%= statusClass %>"><%= status %></span></td>
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
