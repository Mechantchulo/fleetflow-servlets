<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.transportmanager.model.Trip" %>
<%
    Trip selectedRequest = (Trip) request.getAttribute("selectedRequest");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Schedule Request - ATMS</title>
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
            <li class="menu-item">
                <a href="${pageContext.request.contextPath}/timetabling/dashboard"><i class="fas fa-calendar-check"></i><span>Timetable Desk</span></a>
            </li>
            <li class="menu-item active">
                <a href="#"><i class="fas fa-calendar-plus"></i><span>Schedule Request</span></a>
            </li>
        </ul>
        <div class="sidebar-footer">
            <a href="${pageContext.request.contextPath}/logout" class="logout-btn"><i class="fas fa-sign-out-alt"></i><span>Logout</span></a>
        </div>
    </aside>

    <main class="main-content">
        <header class="top-header">
            <div class="header-title">
                <h1>Schedule Staff Request</h1>
                <p class="subtitle">Set final date and budget, then publish this request to timetable</p>
            </div>
            <div class="profile-avatar"><i class="fas fa-calendar-days"></i></div>
        </header>

        <div class="dashboard-content">
            <% if (request.getParameter("error") != null) { %>
            <div class="error-alert"><i class="fas fa-exclamation-circle"></i>Error: <%= request.getParameter("error") %></div>
            <% } %>

            <% if (selectedRequest == null) { %>
                <section class="card">
                    <div class="card-body">
                        <p class="text-muted">Request was not found or has already been scheduled.</p>
                        <a class="btn btn-primary" href="${pageContext.request.contextPath}/timetabling/dashboard">Back to Timetable Desk</a>
                    </div>
                </section>
            <% } else { %>
                <div class="content-split">
                    <section class="card">
                        <div class="card-header"><h3><i class="fas fa-file-lines"></i>Request Details</h3></div>
                        <div class="card-body">
                            <p><strong>Request ID:</strong> <%= selectedRequest.getId() %></p>
                            <p><strong>Requester:</strong> <%= selectedRequest.getRequesterName() == null ? "Staff" : selectedRequest.getRequesterName() %></p>
                            <p><strong>Department:</strong> <%= selectedRequest.getDepartment() == null ? "-" : selectedRequest.getDepartment() %></p>
                            <p><strong>Destination:</strong> <%= selectedRequest.getDestination() == null ? "-" : selectedRequest.getDestination() %></p>
                            <p><strong>Requested Date:</strong> <%= selectedRequest.getDepartureDate() == null ? "-" : selectedRequest.getDepartureDate() %></p>
                            <p><strong>Passengers:</strong> <%= selectedRequest.getPassengerCount() %></p>
                            <p><strong>Requested Budget:</strong> KES <%= selectedRequest.getRequestedBudget() == null ? "0.00" : selectedRequest.getRequestedBudget() %></p>
                            <p><strong>Purpose/Notes:</strong> <%= selectedRequest.getRequestNote() == null || selectedRequest.getRequestNote().isBlank() ? "-" : selectedRequest.getRequestNote() %></p>
                            <p><strong>Attachment:</strong>
                                <% if (selectedRequest.isHasSchedulingDocument()) { %>
                                <a class="btn btn-outline" href="${pageContext.request.contextPath}/staff/requests/document?id=<%= selectedRequest.getId() %>">Download Request PDF</a>
                                <% } else { %>
                                <span class="text-muted">No PDF attached</span>
                                <% } %>
                            </p>
                        </div>
                    </section>

                    <section class="card">
                        <div class="card-header"><h3><i class="fas fa-calendar-plus"></i>Finalize Schedule</h3></div>
                        <div class="card-body">
                            <form method="post" action="${pageContext.request.contextPath}/timetabling/requests/schedule">
                                <input type="hidden" name="tripRequestId" value="<%= selectedRequest.getId() %>">

                                <div class="form-group">
                                    <label for="title">Timetable Title</label>
                                    <input type="text" id="title" name="title" class="form-control" value="Academic Trip - <%= selectedRequest.getDestination() == null ? "Request" : selectedRequest.getDestination() %>" required>
                                </div>
                                <div class="form-group">
                                    <label for="department">Department</label>
                                    <input type="text" id="department" name="department" class="form-control" value="<%= selectedRequest.getDepartment() == null ? "" : selectedRequest.getDepartment() %>" required>
                                </div>
                                <div class="form-group">
                                    <label for="departureTime">Allocated Date/Time</label>
                                    <input type="datetime-local" id="departureTime" name="departureTime" class="form-control" required>
                                </div>
                                <div class="form-group">
                                    <label for="budgetAmount">Final Budget (KES)</label>
                                    <input type="number" step="0.01" id="budgetAmount" name="budgetAmount" min="0" value="<%= selectedRequest.getRequestedBudget() == null ? "0.00" : selectedRequest.getRequestedBudget() %>" class="form-control">
                                </div>

                                <div class="filter-actions">
                                    <a class="btn btn-outline" href="${pageContext.request.contextPath}/timetabling/dashboard">Cancel</a>
                                    <button class="btn btn-primary" type="submit">Publish Scheduled Entry</button>
                                </div>
                            </form>
                        </div>
                    </section>
                </div>
            <% } %>
        </div>
    </main>
</div>
</body>
</html>
