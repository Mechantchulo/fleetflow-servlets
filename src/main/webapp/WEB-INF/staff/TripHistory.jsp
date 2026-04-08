<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Trip History</title>
    <style>
        :root {
            --bg: #eef4f1;
            --panel: #fcfffd;
            --ink: #14232d;
            --muted: #5f7280;
            --line: #cdd9d2;
            --accent: #155e75;
            --accent-soft: #dff2f8;
            --completed: #166534;
            --cancelled: #991b1b;
        }

        * { box-sizing: border-box; }

        body {
            margin: 0;
            font-family: "Segoe UI", Tahoma, sans-serif;
            color: var(--ink);
            background:
                radial-gradient(circle at top right, rgba(21, 94, 117, 0.12), transparent 28%),
                var(--bg);
        }

        .page {
            width: min(1120px, calc(100% - 32px));
            margin: 28px auto 40px;
        }

        .hero,
        .panel {
            background: var(--panel);
            border: 1px solid var(--line);
            border-radius: 18px;
            box-shadow: 0 14px 36px rgba(20, 35, 45, 0.08);
        }

        .hero {
            padding: 24px 28px;
            margin-bottom: 18px;
        }

        .muted {
            color: var(--muted);
        }

        .toolbar {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            justify-content: space-between;
            align-items: center;
            margin-top: 18px;
        }

        .tabs {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }

        .tab {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 14px;
            border-radius: 999px;
            border: 1px solid var(--line);
            color: var(--ink);
            text-decoration: none;
            font-weight: 600;
            background: #fff;
        }

        .tab.active {
            border-color: var(--accent);
            background: var(--accent-soft);
            color: var(--accent);
        }

        .search-form {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }

        .search-form input {
            min-width: min(280px, 100%);
            padding: 10px 12px;
            border-radius: 10px;
            border: 1px solid var(--line);
            background: #fff;
            font: inherit;
        }

        .search-form button,
        .search-form a {
            padding: 10px 14px;
            border-radius: 10px;
            text-decoration: none;
            font-weight: 700;
            font: inherit;
        }

        .search-form button {
            border: 0;
            background: var(--accent);
            color: #fff;
            cursor: pointer;
        }

        .search-form a {
            border: 1px solid var(--line);
            color: var(--ink);
            background: #fff;
        }

        .panel {
            padding: 22px 24px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        th, td {
            text-align: left;
            padding: 13px 10px;
            border-bottom: 1px solid var(--line);
            vertical-align: top;
        }

        th {
            color: var(--muted);
            font-size: 0.9rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        .badge {
            display: inline-block;
            padding: 6px 10px;
            border-radius: 999px;
            font-size: 0.9rem;
            font-weight: 700;
        }

        .badge.completed {
            background: #dcfce7;
            color: var(--completed);
        }

        .badge.cancelled {
            background: #fee2e2;
            color: var(--cancelled);
        }

        .empty {
            margin: 0;
            padding: 18px;
            border: 1px dashed var(--line);
            border-radius: 12px;
            color: var(--muted);
            background: #f7fbf9;
        }
    </style>
</head>
<body>
<%
    String activeTab = (String) request.getAttribute("activeTab");
    String search = (String) request.getAttribute("search");
    java.util.List<com.staff.model.Trip> tripsList =
            (java.util.List<com.staff.model.Trip>) request.getAttribute("trips");
%>
<div class="page">
    <section class="hero">
        <h1>Trip History</h1>
        <p class="muted">Review completed and cancelled trips with quick status filters and route search.</p>
        <div class="toolbar">
            <div class="tabs">
                <a class="tab <%= "all".equalsIgnoreCase(activeTab) ? "active" : "" %>" href="${pageContext.request.contextPath}/staff/TripHistory?tab=all">
                    All
                </a>
                <a class="tab <%= "completed".equalsIgnoreCase(activeTab) ? "active" : "" %>" href="${pageContext.request.contextPath}/staff/TripHistory?tab=completed">
                    Completed <span class="muted">(${completedCount})</span>
                </a>
                <a class="tab <%= "cancelled".equalsIgnoreCase(activeTab) ? "active" : "" %>" href="${pageContext.request.contextPath}/staff/TripHistory?tab=cancelled">
                    Cancelled <span class="muted">(${cancelledCount})</span>
                </a>
            </div>
            <form class="search-form" method="get" action="${pageContext.request.contextPath}/staff/TripHistory">
                <input type="hidden" name="tab" value="<%= activeTab %>">
                <input type="search" name="search" value="<%= search %>" placeholder="Search trip ID, driver, or route">
                <button type="submit">Search</button>
                <a href="${pageContext.request.contextPath}/staff/TripHistory">Reset</a>
            </form>
        </div>
    </section>

    <section class="panel">
        <h2>Trip Results</h2>
        <% if (tripsList == null || tripsList.isEmpty()) { %>
            <p class="empty">No trips matched the current filters.</p>
        <% } else { %>
            <table>
                <thead>
                <tr>
                    <th>ID</th>
                    <th>Date</th>
                    <th>Driver</th>
                    <th>Initials</th>
                    <th>Route</th>
                    <th>Duration</th>
                    <th>Status</th>
                </tr>
                </thead>
                <tbody>
                <% for (com.staff.model.Trip item : tripsList) { %>
                    <%
                        String status = item.getStatus().toLowerCase();
                    %>
                    <tr>
                        <td><%= item.getId() %></td>
                        <td><%= item.getDate() %></td>
                        <td><%= item.getDriver() %></td>
                        <td><%= item.getDriverInitials() %></td>
                        <td><%= item.getRoute() %></td>
                        <td><%= item.getDuration() %></td>
                        <td><span class="badge <%= status %>"><%= item.getStatus() %></span></td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        <% } %>
    </section>
</div>
</body>
</html>
