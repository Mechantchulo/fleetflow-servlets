<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.transportmanager.model.Trip" %>
<%@ page import="java.time.LocalDate" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pending Trip Queue | FleetFlow - Transport Manager</title>
    <style>
        /* BASE STYLES  */
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
        .container {
            max-width: 1200px;
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

        .page-header p {
            color: #7f8c8d;
            font-size: 14px;
        }

        .filter-section {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            margin-bottom: 30px;
        }

        .filter-section h3 {
            font-size: 18px;
            margin-bottom: 15px;
            color: #2c3e50;
        }

        .filter-form {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            align-items: flex-end;
        }

        .form-group {
            display: flex;
            flex-direction: column;
        }

        .form-group label {
            font-size: 14px;
            font-weight: 500;
            margin-bottom: 5px;
            color: #2c3e50;
        }

        .form-group select,
        .form-group input {
            padding: 10px;
            border: 1px solid #bdc3c7;
            border-radius: 4px;
            font-size: 14px;
            transition: border-color 0.3s ease;
        }

        .form-group select:focus,
        .form-group input:focus {
            outline: none;
            border-color: #3498db;
            box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
        }

        .form-actions {
            display: flex;
            gap: 10px;
        }

        .btn-filter {
            background-color: #3498db;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            transition: background-color 0.3s ease;
        }

        .btn-filter:hover {
            background-color: #2980b9;
        }

        .btn-clear {
            background-color: #95a5a6;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            text-decoration: none;
            transition: background-color 0.3s ease;
        }

        .btn-clear:hover {
            background-color: #7f8c8d;
        }

        /* ===== TRIPS TABLE ===== */
        .trips-section {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }

        .trips-section h3 {
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
            cursor: pointer;
            transition: background-color 0.2s ease;
        }

        tbody tr:hover {
            background-color: #f8f9fa;
        }

        .badge {
            display: inline-block;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            text-align: center;
        }

        .badge-high {
            background-color: #e74c3c;
            color: white;
        }

        .badge-medium {
            background-color: #f39c12;
            color: white;
        }

        .badge-low {
            background-color: #27ae60;
            color: white;
        }

        .badge-pending {
            background-color: #9b59b6;
            color: white;
        }

        .btn-action {
            background-color: #3498db;
            color: white;
            padding: 8px 12px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 12px;
            font-weight: 600;
            transition: background-color 0.3s ease;
        }

        .btn-action:hover {
            background-color: #2980b9;
        }

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

        .pagination {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 10px;
            margin-top: 20px;
            padding: 20px;
            background: white;
            border-radius: 0 0 8px 8px;
        }

        .pagination a,
        .pagination span {
            padding: 8px 12px;
            border: 1px solid #bdc3c7;
            border-radius: 4px;
            text-decoration: none;
            color: #2c3e50;
            font-size: 14px;
            transition: all 0.3s ease;
        }

        .pagination a:hover {
            background-color: #3498db;
            color: white;
            border-color: #3498db;
        }

        .pagination span.current {
            background-color: #3498db;
            color: white;
            border-color: #3498db;
        }

        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            animation: fadeIn 0.3s ease;
        }

        .modal.show {
            display: flex;
            justify-content: center;
            align-items: center;
        }

        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        .modal-content {
            background-color: white;
            padding: 30px;
            border-radius: 8px;
            width: 90%;
            max-width: 600px;
            max-height: 80vh;
            overflow-y: auto;
            box-shadow: 0 5px 25px rgba(0, 0, 0, 0.3);
            animation: slideIn 0.3s ease;
        }

        @keyframes slideIn {
            from {
                transform: translateY(-50px);
                opacity: 0;
            }
            to {
                transform: translateY(0);
                opacity: 1;
            }
        }

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            border-bottom: 2px solid #ecf0f1;
            padding-bottom: 15px;
        }

        .modal-header h2 {
            font-size: 24px;
            color: #2c3e50;
            margin: 0;
        }

        .modal-close {
            background: none;
            border: none;
            font-size: 28px;
            cursor: pointer;
            color: #7f8c8d;
            transition: color 0.3s ease;
        }

        .modal-close:hover {
            color: #e74c3c;
        }

        .modal-body {
            margin-bottom: 20px;
        }

        .detail-group {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 20px;
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

        .modal-footer {
            display: flex;
            gap: 10px;
            justify-content: flex-end;
        }

        .btn-close-modal {
            background-color: #95a5a6;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            transition: background-color 0.3s ease;
        }

        .btn-close-modal:hover {
            background-color: #7f8c8d;
        }

        .btn-allocate {
            background-color: #27ae60;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            transition: background-color 0.3s ease;
        }

        .btn-allocate:hover {
            background-color: #229954;
        }

        /* ===== RESPONSIVE DESIGN ===== */
        @media (max-width: 768px) {
            .filter-form {
                grid-template-columns: 1fr;
            }

            .form-actions {
                flex-direction: column;
            }

            .btn-filter,
            .btn-clear {
                width: 100%;
            }

            .detail-group {
                grid-template-columns: 1fr;
            }

            table {
                font-size: 12px;
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
            <h1>Pending Trip Queue</h1>
            <p>Review and allocate buses and drivers to pending trips</p>
        </div>

        <!-- FILTER SECTION -->
        <div class="filter-section">
            <h3>Filter Trips</h3>
            <form method="GET" action="${pageContext.request.contextPath}/manager/trips/pending" class="filter-form">
                <!-- Priority Filter (STICKY) -->
                <div class="form-group">
                    <label for="priority">Priority</label>
                    <select id="priority" name="priority">
                        <option value="">-- All Priorities --</option>
                        <option value="HIGH" <%= "HIGH".equals(request.getAttribute("priority")) ? "selected" : "" %>>High</option>
                        <option value="MEDIUM" <%= "MEDIUM".equals(request.getAttribute("priority")) ? "selected" : "" %>>Medium</option>
                        <option value="LOW" <%= "LOW".equals(request.getAttribute("priority")) ? "selected" : "" %>>Low</option>
                    </select>
                </div>

                <!-- Date From Filter (STICKY) -->
                <div class="form-group">
                    <label for="dateFrom">From Date</label>
                    <input 
                        type="date" 
                        id="dateFrom" 
                        name="dateFrom"
                        value="<%= request.getAttribute("dateFrom") != null ? request.getAttribute("dateFrom") : "" %>">
                </div>

                <!-- Date To Filter (STICKY) -->
                <div class="form-group">
                    <label for="dateTo">To Date</label>
                    <input 
                        type="date" 
                        id="dateTo" 
                        name="dateTo"
                        value="<%= request.getAttribute("dateTo") != null ? request.getAttribute("dateTo") : "" %>">
                </div>

                <!-- Form Actions -->
                <div class="form-actions">
                    <button type="submit" class="btn-filter">Filter</button>
                    <a href="${pageContext.request.contextPath}/manager/trips/pending" class="btn-clear">Clear Filters</a>
                </div>
            </form>
        </div>

        <!-- TRIPS TABLE SECTION -->
        <div class="trips-section">
            <h3>Trips</h3>
            <%
                List<Trip> pendingTrips = (List<Trip>) request.getAttribute("pendingTrips");
                
                if (pendingTrips != null && !pendingTrips.isEmpty()) {
            %>
                <div class="table-wrapper">
                    <table>
                        <thead>
                            <tr>
                                <th>Trip ID</th>
                                <th>Requester</th>
                                <th>Destination</th>
                                <th>Departure Date</th>
                                <th>Passengers</th>
                                <th>Priority</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                for (Trip trip : pendingTrips) {
                                    String priorityBadgeClass = "badge-low";
                                    if ("HIGH".equals(trip.getPriority())) {
                                        priorityBadgeClass = "badge-high";
                                    } else if ("MEDIUM".equals(trip.getPriority())) {
                                        priorityBadgeClass = "badge-medium";
                                    }
                            %>
                                <tr onclick="openModal(<%= trip.getId() %>)">
                                    <td><strong>#<%= trip.getId() %></strong></td>
                                    <td><%= trip.getRequesterName() %></td>
                                    <td><%= trip.getDestination() %></td>
                                    <td><%= trip.getDepartureDate() %></td>
                                    <td><%= trip.getPassengerCount() %></td>
                                    <td><span class="badge <%= priorityBadgeClass %>"><%= trip.getPriority() %></span></td>
                                    <td><span class="badge badge-pending"><%= trip.getStatus() %></span></td>
                                    <td>
                                        <button class="btn-action" onclick="event.stopPropagation(); allocateTrip(<%= trip.getId() %>)">
                                            Allocate
                                        </button>
                                    </td>
                                </tr>
                            <%
                                }
                            %>
                        </tbody>
                    </table>
                </div>

                                // PAGINATION section 
                <div class="pagination">
                    <%
                        Integer pageObj = (Integer) request.getAttribute("page");
                        Integer sizeObj = (Integer) request.getAttribute("size");
                        
                        int page = (pageObj != null) ? pageObj : 1;
                        int size = (sizeObj != null) ? sizeObj : 20;
                        
                        String priority = (String) request.getAttribute("priority");
                        LocalDate dateFrom = (LocalDate) request.getAttribute("dateFrom");
                        LocalDate dateTo = (LocalDate) request.getAttribute("dateTo");
                
                        String queryString = "?size=" + size;
                        if (priority != null && !priority.isEmpty()) {
                            queryString += "&priority=" + priority;
                        }
                        if (dateFrom != null) {
                            queryString += "&dateFrom=" + dateFrom;
                        }
                        if (dateTo != null) {
                            queryString += "&dateTo=" + dateTo;
                        }
                
                        if (page > 1) {
                            String prevQuery = queryString + "&page=" + (page - 1);
                    %>
                        <a href="${pageContext.request.contextPath}/manager/trips/pending<%= prevQuery %>">← Previous</a>
                    <%
                        }
                    %>
                    <span class="current">Page <%= page %></span>
                    <%
                        if (pendingTrips.size() == size) {
                            String nextQuery = queryString + "&page=" + (page + 1);
                    %>
                        <a href="${pageContext.request.contextPath}/manager/trips/pending<%= nextQuery %>">Next →</a>
                    <%
                        }
                    %>
                </div>
            <%
                } else {
            %>
                <!-- EMPTY STATE -->
                <div class="empty-state">
                    <div class="empty-state-icon">📭</div>
                    <p>No pending trips found</p>
                    <p style="font-size: 12px; color: #bdc3c7;">Check back later or adjust your filters</p>
                </div>
            <%
                }
            %>
        </div>
    </div>

    <!-- ===== TRIP DETAILS MODAL ===== -->
    <div id="tripModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Trip Details</h2>
                <button class="modal-close" onclick="closeModal()">&times;</button>
            </div>
            <div class="modal-body">
                <div class="detail-group">
                    <div class="detail-item">
                        <span class="detail-label">Trip ID</span>
                        <span class="detail-value" id="modalTripId"></span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Status</span>
                        <span class="detail-value" id="modalStatus"></span>
                    </div>
                </div>
                <div class="detail-group">
                    <div class="detail-item">
                        <span class="detail-label">Requester Name</span>
                        <span class="detail-value" id="modalRequester"></span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Destination</span>
                        <span class="detail-value" id="modalDestination"></span>
                    </div>
                </div>
                <div class="detail-group">
                    <div class="detail-item">
                        <span class="detail-label">Departure Date</span>
                        <span class="detail-value" id="modalDepartureDate"></span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Passenger Count</span>
                        <span class="detail-value" id="modalPassengers"></span>
                    </div>
                </div>
                <div class="detail-group">
                    <div class="detail-item">
                        <span class="detail-label">Priority</span>
                        <span class="detail-value" id="modalPriority"></span>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn-close-modal" onclick="closeModal()">Close</button>
                <button class="btn-allocate" onclick="proceedToAllocation()">Allocate Bus & Driver</button>
            </div>
        </div>
    </div>

    <script>
        // Store current trip ID for allocation
        let currentTripId = null;
        let tripData = {};

        // Extract and store trip data from table
        <%
            if (pendingTrips != null && !pendingTrips.isEmpty()) {
                for (Trip trip : pendingTrips) {
        %>
                tripData[<%= trip.getId() %>] = {
                    id: <%= trip.getId() %>,
                    requesterName: "<%= trip.getRequesterName() %>",
                    destination: "<%= trip.getDestination() %>",
                    departureDate: "<%= trip.getDepartureDate() %>",
                    passengerCount: <%= trip.getPassengerCount() %>,
                    priority: "<%= trip.getPriority() %>",
                    status: "<%= trip.getStatus() %>"
                };
        <%
                }
            }
        %>

        // Open modal with trip details
        function openModal(tripId) {
            currentTripId = tripId;
            const trip = tripData[tripId];

            if (!trip) return;

            document.getElementById('modalTripId').textContent = '#' + trip.id;
            document.getElementById('modalStatus').textContent = trip.status;
            document.getElementById('modalRequester').textContent = trip.requesterName;
            document.getElementById('modalDestination').textContent = trip.destination;
            document.getElementById('modalDepartureDate').textContent = trip.departureDate;
            document.getElementById('modalPassengers').textContent = trip.passengerCount;
            document.getElementById('modalPriority').textContent = trip.priority;

            document.getElementById('tripModal').classList.add('show');
        }

        // Close modal
        function closeModal() {
            document.getElementById('tripModal').classList.remove('show');
            currentTripId = null;
        }

        // Close modal when clicking outside
        document.getElementById('tripModal').addEventListener('click', function(event) {
            if (event.target === this) {
                closeModal();
            }
        });

        // Proceed to allocation
        function proceedToAllocation() {
            if (!currentTripId) {
                alert('No trip selected');
                return;
            }

            // Redirect to allocation page (we'll create this next)
            // For now, redirect to available buses page with trip ID as parameter
            window.location.href = '${pageContext.request.contextPath}/manager/allocation/buses?tripId=' + currentTripId;
        }

        // Allocate button (alternative approach - direct allocation)
        function allocateTrip(tripId) {
            openModal(tripId);
        }
    </script>
</body>
</html>