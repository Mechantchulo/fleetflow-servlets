<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.Map" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Allocation Summary | FleetFlow - Transport Manager</title>
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
            max-width: 900px;
            margin: 30px auto;
            padding: 0 20px;
        }

        .page-header {
            margin-bottom: 30px;
            text-align: center;
        }

        .page-header h1 {
            font-size: 36px;
            color: #2c3e50;
            margin-bottom: 10px;
        }

        .page-header p {
            color: #7f8c8d;
            font-size: 16px;
        }

        /* ===== SUCCESS CHECKMARK ===== */
        .success-icon {
            width: 80px;
            height: 80px;
            margin: 0 auto 20px;
            background-color: #27ae60;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 48px;
            color: white;
            box-shadow: 0 4px 15px rgba(39, 174, 96, 0.3);
        }

        /* ===== SUMMARY CARDS ===== */
        .summary-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .summary-card {
            background: white;
            padding: 25px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            border-top: 4px solid #3498db;
            text-align: center;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .summary-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        }

        .summary-card h3 {
            font-size: 13px;
            color: #7f8c8d;
            text-transform: uppercase;
            margin-bottom: 12px;
            font-weight: 600;
            letter-spacing: 0.5px;
        }

        .summary-card p {
            font-size: 24px;
            color: #2c3e50;
            font-weight: bold;
            margin: 0;
        }

        .summary-card-blue {
            border-top-color: #3498db;
        }

        .summary-card-green {
            border-top-color: #27ae60;
        }

        .summary-card-orange {
            border-top-color: #f39c12;
        }

        .summary-card-purple {
            border-top-color: #9b59b6;
        }

        /* ===== DETAILS SECTION ===== */
        .details-container {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            overflow: hidden;
            margin-bottom: 30px;
        }

        .details-header {
            background-color: #34495e;
            color: white;
            padding: 20px;
            font-size: 18px;
            font-weight: 600;
        }

        .details-body {
            padding: 30px;
        }

        .details-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
            margin-bottom: 25px;
        }

        .details-row:last-child {
            margin-bottom: 0;
        }

        .detail-item {
            display: flex;
            flex-direction: column;
        }

        .detail-label {
            font-size: 12px;
            color: #7f8c8d;
            text-transform: uppercase;
            font-weight: 600;
            margin-bottom: 8px;
            letter-spacing: 0.5px;
        }

        .detail-value {
            font-size: 18px;
            color: #2c3e50;
            font-weight: 500;
        }

        .detail-value-highlight {
            background-color: #ecf0f1;
            padding: 12px;
            border-radius: 4px;
            font-family: 'Courier New', monospace;
            border-left: 3px solid #3498db;
        }

        /* ===== BADGES ===== */
        .badge {
            display: inline-block;
            padding: 8px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }

        .badge-priority-high {
            background-color: #fadbd8;
            color: #c0392b;
        }

        .badge-priority-medium {
            background-color: #fdebd0;
            color: #d68910;
        }

        .badge-priority-low {
            background-color: #d5f4e6;
            color: #27ae60;
        }

        .badge-status {
            background-color: #e8daef;
            color: #7d3c98;
        }

        /* ===== TIMELINE ===== */
        .allocation-timeline {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-top: 20px;
            padding: 20px;
            background-color: #f8f9fa;
            border-radius: 8px;
        }

        .timeline-step {
            display: flex;
            flex-direction: column;
            align-items: center;
            flex: 1;
        }

        .timeline-icon {
            width: 40px;
            height: 40px;
            background-color: #27ae60;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 20px;
            margin-bottom: 8px;
        }

        .timeline-label {
            font-size: 12px;
            color: #7f8c8d;
            text-align: center;
            font-weight: 600;
        }

        .timeline-arrow {
            color: #27ae60;
            font-size: 24px;
            margin-bottom: 8px;
        }

        /* ===== ACTION BUTTONS ===== */
        .form-actions {
            display: flex;
            gap: 15px;
            justify-content: center;
            margin-top: 30px;
        }

        .btn {
            padding: 14px 32px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-block;
        }

        .btn-back {
            background-color: #3498db;
            color: white;
        }

        .btn-back:hover {
            background-color: #2980b9;
        }

        .btn-home {
            background-color: #27ae60;
            color: white;
        }

        .btn-home:hover {
            background-color: #229954;
        }

        /* ===== ERROR STATE ===== */
        .error-box {
            background-color: #f8d7da;
            border: 1px solid #f5c6cb;
            border-radius: 4px;
            color: #721c24;
            padding: 20px;
            margin-bottom: 20px;
            font-size: 14px;
            text-align: center;
        }

        .error-box::before {
            content: "⚠ ";
            font-weight: bold;
        }

        /* ===== RESPONSIVE DESIGN ===== */
        @media (max-width: 768px) {
            .summary-grid {
                grid-template-columns: repeat(2, 1fr);
            }

            .details-row {
                grid-template-columns: 1fr;
            }

            .allocation-timeline {
                flex-direction: column;
            }

            .timeline-arrow {
                transform: rotate(90deg);
            }

            .form-actions {
                flex-direction: column;
            }

            .btn {
                width: 100%;
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
        <%
            Map<String, Object> summary = (Map<String, Object>) request.getAttribute("summary");
            Long tripId = (Long) request.getAttribute("tripId");

            if (summary != null && !summary.isEmpty()) {
                // Extract data from summary map
                String tripIDStr = summary.get("tripId") != null ? summary.get("tripId").toString() : "N/A";
                String destination = summary.get("destination") != null ? summary.get("destination").toString() : "N/A";
                String requesterName = summary.get("requesterName") != null ? summary.get("requesterName").toString() : "N/A";
                String passengers = summary.get("passengerCount") != null ? summary.get("passengerCount").toString() : "N/A";
                String priority = summary.get("priority") != null ? summary.get("priority").toString() : "N/A";
                String status = summary.get("status") != null ? summary.get("status").toString() : "N/A";
                String busPlateNumber = summary.get("busPlateNumber") != null ? summary.get("busPlateNumber").toString() : "N/A";
                String busCapacity = summary.get("busCapacity") != null ? summary.get("busCapacity").toString() : "N/A";
                String driverName = summary.get("driverName") != null ? summary.get("driverName").toString() : "N/A";
                String driverLicense = summary.get("driverLicense") != null ? summary.get("driverLicense").toString() : "N/A";
                String allocatedAt = summary.get("allocatedAt") != null ? summary.get("allocatedAt").toString() : "N/A";
                String allocatedBy = summary.get("allocatedBy") != null ? summary.get("allocatedBy").toString() : "N/A";
        %>

            <!-- PAGE HEADER -->
            <div class="page-header">
                <div class="success-icon">✓</div>
                <h1>Allocation Complete!</h1>
                <p>Trip has been successfully allocated</p>
            </div>

            <!-- SUMMARY STATS -->
            <div class="summary-grid">
                <div class="summary-card summary-card-blue">
                    <h3>Trip ID</h3>
                    <p>#<%= tripIDStr %></p>
                </div>
                <div class="summary-card summary-card-green">
                    <h3>Destination</h3>
                    <p style="font-size: 16px;"><%= destination %></p>
                </div>
                <div class="summary-card summary-card-orange">
                    <h3>Passengers</h3>
                    <p><%= passengers %></p>
                </div>
                <div class="summary-card summary-card-purple">
                    <h3>Priority</h3>
                    <p style="font-size: 16px;">
                        <%
                            String badgeClass = "badge-priority-low";
                            if ("HIGH".equals(priority)) badgeClass = "badge-priority-high";
                            else if ("MEDIUM".equals(priority)) badgeClass = "badge-priority-medium";
                        %>
                        <span class="badge <%= badgeClass %>"><%= priority %></span>
                    </p>
                </div>
            </div>

            <!-- TRIP DETAILS -->
            <div class="details-container">
                <div class="details-header">Trip Information</div>
                <div class="details-body">
                    <div class="details-row">
                        <div class="detail-item">
                            <span class="detail-label">Requester Name</span>
                            <span class="detail-value"><%= requesterName %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Trip Status</span>
                            <span class="detail-value"><span class="badge badge-status"><%= status %></span></span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- BUS ALLOCATION DETAILS -->
            <div class="details-container">
                <div class="details-header">🚌 Bus Allocation</div>
                <div class="details-body">
                    <div class="details-row">
                        <div class="detail-item">
                            <span class="detail-label">Plate Number</span>
                            <span class="detail-value detail-value-highlight"><%= busPlateNumber %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Bus Capacity</span>
                            <span class="detail-value"><%= busCapacity %> seats</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- DRIVER ALLOCATION DETAILS -->
            <div class="details-container">
                <div class="details-header">👤 Driver Allocation</div>
                <div class="details-body">
                    <div class="details-row">
                        <div class="detail-item">
                            <span class="detail-label">Driver Name</span>
                            <span class="detail-value"><%= driverName %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">License Number</span>
                            <span class="detail-value detail-value-highlight"><%= driverLicense %></span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- ALLOCATION METADATA -->
            <div class="details-container">
                <div class="details-header">📋 Allocation Record</div>
                <div class="details-body">
                    <div class="details-row">
                        <div class="detail-item">
                            <span class="detail-label">Allocated By</span>
                            <span class="detail-value"><%= allocatedBy %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Allocated At</span>
                            <span class="detail-value"><%= allocatedAt %></span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- ALLOCATION TIMELINE -->
            <div class="allocation-timeline">
                <div class="timeline-step">
                    <div class="timeline-icon">1</div>
                    <div class="timeline-label">Trip<br>Received</div>
                </div>
                <div class="timeline-arrow">→</div>
                <div class="timeline-step">
                    <div class="timeline-icon">2</div>
                    <div class="timeline-label">Bus<br>Selected</div>
                </div>
                <div class="timeline-arrow">→</div>
                <div class="timeline-step">
                    <div class="timeline-icon">3</div>
                    <div class="timeline-label">Driver<br>Selected</div>
                </div>
                <div class="timeline-arrow">→</div>
                <div class="timeline-step">
                    <div class="timeline-icon">✓</div>
                    <div class="timeline-label">Allocation<br>Complete</div>
                </div>
            </div>

            <!-- ACTION BUTTONS -->
            <div class="form-actions">
                <a href="${pageContext.request.contextPath}/manager/trips/pending" class="btn btn-home">
                    ← Back to Pending Trips
                </a>
                <a href="${pageContext.request.contextPath}/manager/trips/pending" class="btn btn-back">
                    Allocate Next Trip →
                </a>
            </div>

        <%
            } else {
        %>
            <!-- ERROR STATE -->
            <div class="error-box">
                ⚠ No allocation summary found. The allocation may not have been completed successfully.
            </div>
            <div class="form-actions" style="margin-top: 30px;">
                <a href="${pageContext.request.contextPath}/manager/trips/pending" class="btn btn-home">
                    ← Back to Pending Trips
                </a>
            </div>
        <%
            }
        %>
    </div>
</body>
</html>
