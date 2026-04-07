<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.transportmanager.model.Bus" %>
<%@ page import="com.transportmanager.model.Trip" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Allocate Bus | FleetFlow - Transport Manager</title>
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

        /* ===== TRIP DETAILS CARD ===== */
        .trip-details {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            margin-bottom: 30px;
            border-left: 5px solid #3498db;
        }

        .trip-details h2 {
            font-size: 20px;
            margin-bottom: 15px;
            color: #2c3e50;
        }

        .detail-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
        }

        .detail-item {
            display: flex;
            flex-direction: column;
        }

        .detail-label {
            font-size: 12px;
            font-weight: 600;
            color: #7f8c8d;
            text-transform: uppercase;
            margin-bottom: 5px;
        }

        .detail-value {
            font-size: 16px;
            color: #2c3e50;
            font-weight: 500;
        }

        .capacity-warning {
            background-color: #fff3cd;
            border: 1px solid #ffc107;
            border-radius: 4px;
            padding: 10px 15px;
            margin-top: 15px;
            color: #856404;
            font-size: 13px;
        }

        /* ===== BUSES SECTION ===== */
        .buses-section {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            overflow: hidden;
            margin-bottom: 20px;
        }

        .buses-section h3 {
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

        tbody tr {
            transition: background-color 0.2s ease;
        }

        tbody tr:hover {
            background-color: #f8f9fa;
        }

        .bus-select-radio {
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

        .badge-maintenance {
            background-color: #f39c12;
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

        .btn-next {
            background-color: #27ae60;
            color: white;
        }

        .btn-next:hover {
            background-color: #229954;
        }

        .btn-next:disabled {
            background-color: #bdc3c7;
            cursor: not-allowed;
        }

        /* ===== RESPONSIVE DESIGN ===== */
        @media (max-width: 768px) {
            .detail-grid {
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
            <h1>Select Bus for Trip</h1>
            <div class="breadcrumb">
                <a href="${pageContext.request.contextPath}/manager/trips/pending">Pending Trips</a>
                &nbsp;→&nbsp;
                <span>Select Bus</span>
                &nbsp;→&nbsp;
                <span style="color: #bdc3c7;">Select Driver</span>
            </div>
        </div>

        <!-- ERROR MESSAGE -->
        <%
            String error = request.getParameter("error");
            if (error != null && !error.isEmpty()) {
                String errorMessage = "An error occurred";
                if ("invalidTripId".equals(error)) errorMessage = "Invalid trip ID provided.";
                if ("busLookupFailed".equals(error)) errorMessage = "Failed to load buses from database.";
                if ("busUnavailable".equals(error)) errorMessage = "Selected bus is no longer available.";
                if ("assignBusFirst".equals(error)) errorMessage = "Bus must be selected first.";
        %>
            <div class="error-box"><%= errorMessage %></div>
        <%
            }
        %>

        <!-- TRIP DETAILS -->
        <%
            Trip trip = (Trip) request.getAttribute("trip");
            Integer requiredCapacity = (Integer) request.getAttribute("requiredCapacity");
            Long tripId = (Long) request.getAttribute("tripId");
            
            if (trip != null) {
        %>
            <div class="trip-details">
                <h2>Trip Information</h2>
                <div class="detail-grid">
                    <div class="detail-item">
                        <span class="detail-label">Trip ID</span>
                        <span class="detail-value">#<%= trip.getId() %></span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Destination</span>
                        <span class="detail-value"><%= trip.getDestination() %></span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Requester</span>
                        <span class="detail-value"><%= trip.getRequesterName() %></span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Passengers</span>
                        <span class="detail-value"><%= trip.getPassengerCount() %></span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Departure Date</span>
                        <span class="detail-value"><%= trip.getDepartureDate() %></span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Priority</span>
                        <span class="detail-value"><%= trip.getPriority() %></span>
                    </div>
                </div>
                <div class="capacity-warning">
                    ⓘ Required Bus Capacity: <strong><%= requiredCapacity %> passengers</strong>
                </div>
            </div>
        <%
            }
        %>

        <!-- BUSES TABLE -->
        <div class="buses-section">
            <h3>Available Buses</h3>
            <%
                List<Bus> availableBuses = (List<Bus>) request.getAttribute("availableBuses");
                
                if (availableBuses != null && !availableBuses.isEmpty()) {
            %>
                <form id="busSelectionForm" method="POST" action="${pageContext.request.contextPath}/manager/allocation/bus/assign">
                    <input type="hidden" name="tripId" value="<%= tripId %>">
                    
                    <div class="table-wrapper">
                        <table>
                            <thead>
                                <tr>
                                    <th style="width: 60px;"></th>
                                    <th>Plate Number</th>
                                    <th>Capacity</th>
                                    <th>Mileage</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    for (Bus bus : availableBuses) {
                                        boolean capacitySufficient = bus.getCapacity() >= requiredCapacity;
                                        String capacityClass = capacitySufficient ? "" : "insufficient-capacity";
                                %>
                                    <tr class="<%= capacityClass %>">
                                        <td>
                                            <input 
                                                type="radio" 
                                                name="busId" 
                                                value="<%= bus.getId() %>"
                                                class="bus-select-radio"
                                                onchange="updateForm()">
                                        </td>
                                        <td><strong><%= bus.getPlateNumber() %></strong></td>
                                        <td><%= bus.getCapacity() %> seats</td>
                                        <td><%= bus.getMileage() %> km</td>
                                        <td><span class="badge badge-available"><%= bus.getStatus() %></span></td>
                                    </tr>
                                <%
                                    }
                                %>
                            </tbody>
                        </table>
                    </div>

                    <!-- OVERRIDE SECTION -->
                    <div class="override-section" id="overrideSection">
                        <h4>⚠ Bus Capacity Warning</h4>
                        <div class="form-group">
                            <input 
                                type="checkbox" 
                                id="overrideCheckbox" 
                                name="override" 
                                class="checkbox"
                                onchange="toggleOverrideReason()">
                            <label for="overrideCheckbox">
                                I understand the capacity concern and want to proceed with this bus
                            </label>
                        </div>

                        <div class="override-reason-group" id="overrideReasonGroup">
                            <label for="overrideReason">Why are you overriding this capacity concern? (Required)</label>
                            <textarea 
                                id="overrideReason" 
                                name="overrideReason" 
                                placeholder="Provide a reason for this override..."></textarea>
                            <small style="color: #7f8c8d;">This will be logged for audit purposes.</small>
                        </div>
                    </div>

                    <!-- ACTION BUTTONS -->
                    <div class="form-actions">
                        <a href="${pageContext.request.contextPath}/manager/trips/pending" class="btn btn-back">← Back to Pending Trips</a>
                        <button type="submit" class="btn btn-next" id="nextButton" disabled>
                            Next: Select Driver →
                        </button>
                    </div>
                </form>
            <%
                } else {
            %>
                <!-- EMPTY STATE -->
                <div class="empty-state">
                    <div class="empty-state-icon">🚌</div>
                    <p>No available buses found</p>
                    <p style="font-size: 12px; color: #bdc3c7;">
                        All buses are currently allocated or under maintenance.<br>
                        Please try again later.
                    </p>
                </div>
            <%
                }
            %>
        </div>
    </div>

    <!-- ===== JAVASCRIPT ===== -->
    <script>
        const busCapacityRequired = <%= requiredCapacity != null ? requiredCapacity : 0 %>;

        // Update form state based on bus selection
        function updateForm() {
            const selectedBus = document.querySelector('input[name="busId"]:checked');
            const nextButton = document.getElementById('nextButton');
            const overrideSection = document.getElementById('overrideSection');

            if (selectedBus) {
                nextButton.disabled = false;

                // Check if selected bus capacity is insufficient
                const selectedRow = selectedBus.closest('tr');
                const capacityCell = selectedRow.cells[2];
                const capacity = parseInt(capacityCell.textContent.match(/\d+/)[0]);

                if (capacity < busCapacityRequired) {
                    overrideSection.classList.add('show');
                } else {
                    overrideSection.classList.remove('show');
                    // Clear override values if bus has sufficient capacity
                    document.getElementById('overrideCheckbox').checked = false;
                    document.getElementById('overrideReasonGroup').classList.remove('show');
                }
            } else {
                nextButton.disabled = true;
                overrideSection.classList.remove('show');
            }
        }

        // Toggle override reason textarea
        function toggleOverrideReason() {
            const checkbox = document.getElementById('overrideCheckbox');
            const reasonGroup = document.getElementById('overrideReasonGroup');

            if (checkbox.checked) {
                reasonGroup.classList.add('show');
                document.getElementById('overrideReason').focus();
            } else {
                reasonGroup.classList.remove('show');
                document.getElementById('overrideReason').value = '';
            }
        }

        // Form submission validation
        document.getElementById('busSelectionForm').addEventListener('submit', function(e) {
            const selectedBus = document.querySelector('input[name="busId"]:checked');
            const overrideCheckbox = document.getElementById('overrideCheckbox');
            const overrideReason = document.getElementById('overrideReason').value.trim();

            if (!selectedBus) {
                e.preventDefault();
                alert('Please select a bus');
                return false;
            }

            if (overrideCheckbox.checked && !overrideReason) {
                e.preventDefault();
                alert('Please provide a reason for overriding the capacity concern');
                document.getElementById('overrideReason').focus();
                return false;
            }

            return true;
        });
    </script>
</body>
</html>
