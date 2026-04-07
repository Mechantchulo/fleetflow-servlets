<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>My Requests</title>
    <style>
        :root {
            --bg: #f3efe5;
            --panel: #fffdf9;
            --ink: #1f2933;
            --muted: #677282;
            --line: #ddd3c3;
            --accent: #9a3412;
            --accent-soft: #fce7d6;
            --pending: #92400e;
            --approved: #166534;
            --rejected: #991b1b;
        }

        * { box-sizing: border-box; }

        body {
            margin: 0;
            font-family: "Segoe UI", Tahoma, sans-serif;
            color: var(--ink);
            background:
                linear-gradient(180deg, rgba(154, 52, 18, 0.08), transparent 220px),
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
            box-shadow: 0 14px 36px rgba(31, 41, 51, 0.08);
        }

        .hero {
            padding: 24px 28px;
            margin-bottom: 18px;
        }

        .hero h1,
        .panel h2 {
            margin-top: 0;
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

        .badge.pending {
            background: #ffedd5;
            color: var(--pending);
        }

        .badge.approved {
            background: #dcfce7;
            color: var(--approved);
        }

        .badge.rejected {
            background: #fee2e2;
            color: var(--rejected);
        }

        .empty {
            margin: 0;
            padding: 18px;
            border: 1px dashed var(--line);
            border-radius: 12px;
            color: var(--muted);
            background: #fffcf7;
        }
    </style>
</head>
<body>
<%
    String activeTab = (String) request.getAttribute("activeTab");
    String search = (String) request.getAttribute("search");
    java.util.List<com.staff.model.Request> requestsList =
            (java.util.List<com.staff.model.Request>) request.getAttribute("requests");
%>
<div class="page">
    <section class="hero">
        <h1>My Requests</h1>
        <p class="muted">Track every request, filter by status, and search by ID, driver, or destination.</p>
        <div class="toolbar">
            <div class="tabs">
                <a class="tab <%= "all".equalsIgnoreCase(activeTab) ? "active" : "" %>" href="${pageContext.request.contextPath}/staff/myRequests?tab=all">
                    All
                </a>
                <a class="tab <%= "pending".equalsIgnoreCase(activeTab) ? "active" : "" %>" href="${pageContext.request.contextPath}/staff/myRequests?tab=pending">
                    Pending <span class="muted">(${pendingCount})</span>
                </a>
                <a class="tab <%= "approved".equalsIgnoreCase(activeTab) ? "active" : "" %>" href="${pageContext.request.contextPath}/staff/myRequests?tab=approved">
                    Approved <span class="muted">(${approvedCount})</span>
                </a>
                <a class="tab <%= "rejected".equalsIgnoreCase(activeTab) ? "active" : "" %>" href="${pageContext.request.contextPath}/staff/myRequests?tab=rejected">
                    Rejected <span class="muted">(${rejectedCount})</span>
                </a>
            </div>
            <form class="search-form" method="get" action="${pageContext.request.contextPath}/staff/myRequests">
                <input type="hidden" name="tab" value="<%= activeTab %>">
                <input type="search" name="search" value="<%= search %>" placeholder="Search request ID, driver, or destination">
                <button type="submit">Search</button>
                <a href="${pageContext.request.contextPath}/staff/myRequests">Reset</a>
            </form>
        </div>
    </section>

    <section class="panel">
        <h2>Request Results</h2>
        <% if (requestsList == null || requestsList.isEmpty()) { %>
            <p class="empty">No requests matched the current filters.</p>
        <% } else { %>
            <table>
                <thead>
                <tr>
                    <th>ID</th>
                    <th>Date</th>
                    <th>Driver</th>
                    <th>Initials</th>
                    <th>Destination</th>
                    <th>Status</th>
                </tr>
                </thead>
                <tbody>
                <% for (com.staff.model.Request item : requestsList) { %>
                    <%
                        String status = item.getStatus().toLowerCase();
                    %>
                    <tr>
                        <td><%= item.getId() %></td>
                        <td><%= item.getDate() %></td>
                        <td><%= item.getDriver() %></td>
                        <td><%= item.getDriverInitials() %></td>
                        <td><%= item.getDestination() %></td>
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
