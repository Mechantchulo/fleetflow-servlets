<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.transportmanager.model.Driver" %>
<%@ page import="com.transportmanager.model.Trip" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Allocate Driver | FleetFlow - Transport Manager</title>
    <style>
        /* ===== RESET & BASE STYLES ===== */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f5f5f5;
            color: #333;
        }

        /* ===== NAVBAR ===== */
        .navbar {
            background-color: #2c3e50;
            padding: 15px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
            color: white;
        }

        .navbar-brand {
            font-size: 24px;
            font-weight: bold;
            text-decoration: none;
            color: #fff;
        }

        .navbar-right {
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .navbar-user {
            font-size: 14px;
        }

        .btn-logout {
            background-color: #e74c3c;
            color: white;
            padding: 8px 16px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            transition: background-color 0.3s ease;
        }

        .btn-logout:hover {
            background-color: #c0392b;
        }

        /* ===== MAIN CONTAINER ===== */
        .container {
            max-width: 1000px;
            margin: 30px auto;
            padding: 0 20px;
        }

        .page-header {
            margin-bottom: 30px;
        }

        .page-header h1 {
            font-size: 32px;
            color: #2c3e50;
            margin-bottom: 5px;
        }

        .breadcrumb {
            color: #7f8c8d;
            font-size: 14px;
            margin-bottom: 15px;
        }

        .breadcrumb a {
            color: #3498db;
            text-decoration: none;
        }

        .breadcrumb a:hover {
            text-decoration: underline;
        }

        /* ===== ERROR MESSAGE ===== */
        .error-box {
            background-color: #f8d7da;
            border: 1px solid #f5c6cb;
            border-radius: 4px;
            color: #721c24;
            padding: 15px;
            margin-bottom: 20px;
            font-size: 14px;
        }

        .error-box::before {
            content: "⚠ ";
            font-weight: bold;
        }

        /* ===== SUCCESS MESSAGE ===== */
        .success-box {
            background-color: #d4edda;
            border: 1px solid #c3e6cb;
            border-radius: 4px;
            color: #155724;
            padding: 15px;
            margin-bottom: 20px;
            font-size: 14px;
        }

        /* ===== INFO CARD ===== */
        .info-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 15px;
            margin-bottom: 30px;
        }

        .info-card {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            border-left: 4px solid #3498db;
        }

        .info-card h4 {
            font-size: 12px;
            color: #7f8c8d;
            text-transform: uppercase;
            margin-bottom: 8px;
            font-weight: 600;
        }

        .info-card p {
            font-size: 18px;
            color: #2c3e50;
            font-weight: 600;
            margin: 0;
        }

        .info-card-warning {
            border-left-color: #f39c12;
            background-color: #fffbea;
        }

        .info-card-warning h4 {
            color: #856404;
        }

        /* ===== DRIVERS SECTION ===== */
        .drivers-section {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            overflow: hidden;
            margin-bottom: 20px;
        }

        .drivers-section h3 {
            padding: 20px;
            background-color: #34495e;
            color: white;
            margin: 0;
            font-size: 18px;
        }

        .table-wrapper {
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        thead {
            background-color: #ecf0f1;
        }

        thead th {
            padding: 15px;
            text-align: left;
            font-weight: 600;
            color: #2c3e50;
            border-bottom: 2px solid #bdc3c7;
            font-size: 14px;
        }

        tbody td {
            padding: 15px;
            border-bottom: 1px solid #ecf0f1;
            font-size: 14px;
        }

        tbody tr:hover {
            background-color: #f8f9fa;
        }

        .driver-select-radio {
            width: 18px;
            height: 18px;
            cursor: pointer;
        }

        .badge {
            display: inline-block;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            text-align: center;
        }

        .badge-available {
            background-color: #27ae60;
            color: white;
        }

        /* ===== EMPTY STATE ===== */
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #7f8c8d;
        }

        .empty-state-icon {
            font-size: 64px;
            margin-bottom: 20px;
        }

        .empty-state p {
            font-size: 16px;
            margin-bottom: 10px;
        }

        /* ===== OVERRIDE SECTION ===== */
        .override-section {
            background: #fffbea;
            border: 1px solid #ffc107;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
            display: none;
        }

        .override-section.show {
            display: block;
        }

        .override-section h4 {
            color: #856404;
            margin-bottom: 15px;
            font-size: 16px;
        }

        .form-group {
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .form-group label {
            font-size: 14px;
            font-weight: 500;
            margin: 0;
            cursor: pointer;
        }

        .checkbox {
            width: 18px;
            height: 18px;
            cursor: pointer;
        }

        .override-reason-group {
            margin-top: 15px;
            display: none;
        }

        .override-reason-group.show {
            display: block;
        }

        .override-reason-group label {
            display: block;
            font-size: 14px;
            font-weight: 500;
            margin-bottom: 8px;
            color: #2c3e50;
        }

        textarea {
            width: 100%;
            padding: 12px;
            border: 1px solid #bdc3c7;
            border-radius: 4px;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            font-size: 14px;
            resize: vertical;
            min-height: 100px;
            transition: border-color 0.3s ease;
        }

        textarea:focus {
            outline: none;
            border-color: #3498db;
            box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
        }

        /* ===== ACTION BUTTONS ===== */
        .form-actions {
            display: flex;
            gap: 15px;
            justify-content: flex-end;
            margin-top: 30px;
        }

        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        .btn-back {
            background-color: #95a5a6;
            color: white;
        }

        .btn-back:hover {
            background-color: #7f8c8d;
        }

        .btn-confirm {
            background-color: #27ae60;
            color: white;
        }

        .btn-confirm:hover {
            background-color: #229954;
        }

        .btn-confirm:disabled {
            background-color: #bdc3c7;
            cursor: not-allowed;
        }

        /* ===== RESPONSIVE DESIGN ===== */
        @media (max-width: 768px) {
            .info-cards {
                grid-template-columns: 1fr;
            }

            .form-actions {
                flex-direction: column;
            }

            .btn {
                width: 100%;
            }

            thead th,
            tbody td {
                padding: 10px;
            }

            .navbar {
                flex-direction: column;
                gap: 10px;
            }

            .navbar-right {
                width: 100%;
                justify-content: space-between;
            }
        }
    </style>
</head>
<body>
    <!-- ===== NAVBAR ===== -->
    <nav class="navbar">
        <a href="${pageContext.request.contextPath}/manager/trips/pending" class="navbar-brand">FleetFlow</a>
        <div class="navbar-right">
            <div class="navbar-user">
                Logged in as: <strong>${sessionScope.managerUsername}</strong>
            </div>
            <a href="${pageContext.request.contextPath}/manager/logout" class="btn-logout">Logout</a>
        </div>
    </nav>

    <!-- ===== MAIN CONTAINER ===== -->
    <div class="container">
        <!-- PAGE HEADER -->
        <div class="page-header">
            <h1>Select Driver for Trip</h1>
            <div class="breadcrumb">
                <a href="${pageContext.request.contextPath}/manager/trips/pending">Pending Trips</a>
                &nbsp;→&nbsp;
                <a href="${pageContext.request.contextPath}/manager/allocation/buses?tripId=${requestScope.tripId}">Select Bus</a>
                &nbsp;→&nbsp;
                <span>Select Driver</span>
            </div>
        </div>

        <!-- ERROR MESSAGE -->
        <%
            String error = request.getParameter("error");
            if (error != null && !error.isEmpty()) {
                String errorMessage = "An error occurred";
                if ("invalidTripId".equals(error)) errorMessage = "Invalid trip ID provided.";
                if ("driverLookupFailed".equals(error)) errorMessage = "Failed to load drivers from database.";
                if ("driverUnavailable".equals(error)) errorMessage = "Selected driver is no longer available.";
                if ("assignBusFirst".equals(error)) errorMessage = "Bus must be selected first. Please go back.";
                if ("invalidAssignInput".equals(error)) errorMessage = "Invalid input. Please check your selections.";
                if ("overrideReasonRequired".equals(error)) errorMessage = "Override reason is required when overriding availability.";
        %>
            <div class="error-box"><%= errorMessage %></div>
        <%
            }
        %>

        <!-- SUCCESS MESSAGE -->
        <%
            String success = request.getParameter("success");
            if (success != null && !success.isEmpty()) {
        %>
            <div class="success-box">✓ Bus selected successfully. Now select a driver.</div>
        <%
            }
        %>

        <!-- INFO CARDS -->
        <%
            Trip trip = (Trip) request.getAttribute("trip");
            Long selectedBusId = (Long) request.getAttribute("selectedBusId");
            Long tripId = (Long) request.getAttribute("tripId");
            Boolean override = (Boolean) request.getAttribute("override");
            String overrideReason = (String) request.getAttribute("overrideReason");
            
            if (trip != null && selectedBusId != null) {
        %>
            <div class="info-cards">
                <div class="info-card">
                    <h4>Trip ID</h4>
                    <p>#<%= trip.getId() %></p>
                </div>
                <div class="info-card">
                    <h4>Destination</h4>
                    <p><%= trip.getDestination() %></p>
                </div>
                <div class="info-card">
                    <h4>Passengers</h4>
                    <p><%= trip.getPassengerCount() %></p>
                </div>
                <div class="info-card">
                    <h4>Departure</h4>
                    <p><%= trip.getDepartureDate() %></p>
                </div>
                <%
                    if (override != null && override) {
                %>
                    <div class="info-card info-card-warning">
                        <h4>⚠ Bus Override Active</h4>
                        <p style="font-size: 12px; font-weight: normal;">Bus allocated with override applied</p>
                    </div>
                <%
                    }
                %>
            </div>
        <%
            }
        %>

        <!-- DRIVERS TABLE -->
        <div class="drivers-section">
            <h3>Available Drivers</h3>
            <%
                List<Driver> availableDrivers = (List<Driver>) request.getAttribute("availableDrivers");
                
                if (availableDrivers != null && !availableDrivers.isEmpty()) {
            %>
                <form id="driverSelectionForm" method="POST" action="${pageContext.request.contextPath}/manager/allocation/driver/assign">
                    <input type="hidden" name="tripId" value="<%= tripId %>">
                    
                    <div class="table-wrapper">
                        <table>
                            <thead>
                                <tr>
                                    <th style="width: 60px;"></th>
                                    <th>Full Name</th>
                                    <th>License Number</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    for (Driver driver : availableDrivers) {
                                %>
                                    <tr>
                                        <td>
                                            <input 
                                                type="radio" 
                                                name="driverId" 
                                                value="<%= driver.getId() %>"
                                                class="driver-select-radio"
                                                onchange="updateForm()">
                                        </td>
                                        <td><strong><%= driver.getFullName() %></strong></td>
                                        <td><%= driver.getLicenseNumber() %></td>
                                        <td><span class="badge badge-available"><%= driver.getStatus() %></span></td>
                                    </tr>
                                <%
                                    }
                                %>
                            </tbody>
                        </table>
                    </div>

                    <!-- OVERRIDE SECTION (if bus override is active) -->
                    <%
                        if (override != null && override && overrideReason != null) {
                    %>
                        <div class="override-section show">
                            <h4>⚠ Bus Allocation Override Active</h4>
                            <p style="margin: 0; font-size: 13px; color: #856404;">
                                <strong>Reason:</strong> <%= overrideReason %>
                            </p>
                        </div>
                    <%
                        }
                    %>

                    <!-- ACTION BUTTONS -->
                    <div class="form-actions">
                        <a href="${pageContext.request.contextPath}/manager/allocation/buses?tripId=<%= tripId %>" class="btn btn-back">← Back: Select Bus</a>
                        <button type="submit" class="btn btn-confirm" id="confirmButton" disabled>
                            Complete Allocation ✓
                        </button>
                    </div>
                </form>
            <%
                } else {
            %>
                <!-- EMPTY STATE -->
                <div class="empty-state">
                    <div class="empty-state-icon">👤</div>
                    <p>No available drivers found</p>
                    <p style="font-size: 12px; color: #bdc3c7;">
                        All drivers are currently assigned or unavailable.<br>
                        Please try again later or select a different bus.
                    </p>
                </div>
            <%
                }
            %>
        </div>
    </div>

    <!-- ===== JAVASCRIPT ===== -->
    <script>
        // Update form state based on driver selection
        function updateForm() {
            const selectedDriver = document.querySelector('input[name="driverId"]:checked');
            const confirmButton = document.getElementById('confirmButton');

            if (selectedDriver) {
                confirmButton.disabled = false;
            } else {
                confirmButton.disabled = true;
            }
        }

        // Form submission validation
        document.getElementById('driverSelectionForm').addEventListener('submit', function(e) {
            const selectedDriver = document.querySelector('input[name="driverId"]:checked');

            if (!selectedDriver) {
                e.preventDefault();
                alert('Please select a driver');
                return false;
            }

            return true;
        });
    </script>
</body>
</html>
