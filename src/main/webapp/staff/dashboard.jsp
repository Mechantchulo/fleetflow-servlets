<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Staff Dashboard</title>
    <style>
        :root {
            color-scheme: light;
            --bg: #f5f1e8;
            --panel: #fffdf8;
            --ink: #1f2933;
            --muted: #6b7280;
            --line: #d8cdbb;
            --accent: #0f766e;
            --accent-dark: #115e59;
            --warn: #b45309;
            --ok: #166534;
        }

        * { box-sizing: border-box; }

        body {
            margin: 0;
            font-family: "Segoe UI", Tahoma, sans-serif;
            background:
                radial-gradient(circle at top left, rgba(15, 118, 110, 0.12), transparent 32%),
                linear-gradient(180deg, #f7f2e9 0%, var(--bg) 100%);
            color: var(--ink);
        }

        .page {
            width: min(1100px, calc(100% - 32px));
            margin: 32px auto 48px;
        }

        .hero,
        .panel {
            background: var(--panel);
            border: 1px solid var(--line);
            border-radius: 18px;
            box-shadow: 0 14px 40px rgba(31, 41, 51, 0.08);
        }

        .hero {
            padding: 28px;
            margin-bottom: 20px;
        }

        h1, h2, h3 {
            margin-top: 0;
        }

        .muted {
            color: var(--muted);
        }

        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 16px;
            margin: 20px 0 0;
        }

        .stat {
            background: #fcfaf4;
            border: 1px solid var(--line);
            border-radius: 14px;
            padding: 18px;
        }

        .stat strong {
            display: block;
            font-size: 1.9rem;
            margin-top: 8px;
        }

        .layout {
            display: grid;
            grid-template-columns: minmax(280px, 360px) 1fr;
            gap: 20px;
        }

        .panel {
            padding: 24px;
        }

        form {
            display: grid;
            gap: 14px;
        }

        label {
            display: grid;
            gap: 6px;
            font-weight: 600;
        }

        input {
            width: 100%;
            padding: 11px 12px;
            border: 1px solid var(--line);
            border-radius: 10px;
            background: #fff;
            font: inherit;
        }

        button {
            border: 0;
            border-radius: 10px;
            padding: 12px 16px;
            background: var(--accent);
            color: #fff;
            font: inherit;
            font-weight: 700;
            cursor: pointer;
        }

        button:hover {
            background: var(--accent-dark);
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        th, td {
            text-align: left;
            padding: 12px 10px;
            border-bottom: 1px solid var(--line);
            vertical-align: top;
        }

        th {
            font-size: 0.92rem;
            color: var(--muted);
            text-transform: uppercase;
            letter-spacing: 0.04em;
        }

        .status {
            display: inline-block;
            padding: 6px 10px;
            border-radius: 999px;
            background: #e6f6f4;
            color: var(--accent-dark);
            font-weight: 700;
            font-size: 0.9rem;
        }

        .empty {
            margin: 0;
            padding: 18px;
            border: 1px dashed var(--line);
            border-radius: 12px;
            color: var(--muted);
            background: #fcfaf4;
        }

        .links {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            margin-top: 18px;
        }

        .links a {
            color: var(--accent-dark);
            text-decoration: none;
            font-weight: 600;
        }

        @media (max-width: 860px) {
            .layout {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
<div class="page">
    <section class="hero">
        <h1>Staff Transport Dashboard</h1>
        <p class="muted">Monitor request volume, submit a new transport request, and review the latest activity.</p>
        <div class="stats">
            <div class="stat">
                <span class="muted">Total Requests</span>
                <strong>${totalRequests}</strong>
            </div>
            <div class="stat">
                <span class="muted">Approved</span>
                <strong>${approvedRequests}</strong>
            </div>
            <div class="stat">
                <span class="muted">Pending</span>
                <strong>${pendingRequests}</strong>
            </div>
        </div>
        <div class="links">
            <a href="${pageContext.request.contextPath}/staff/myRequests">My Requests</a>
            <a href="${pageContext.request.contextPath}/staff/TripHistory">Trip History</a>
        </div>
    </section>

    <section class="layout">
        <div class="panel">
            <h2>New Bus Request</h2>
            <form method="post" action="${pageContext.request.contextPath}/dashboard">
                <label for="purpose">Purpose
                    <input id="purpose" name="purpose" type="text" placeholder="Field visit, airport pickup, team transfer" required>
                </label>
                <label for="destination">Destination
                    <input id="destination" name="destination" type="text" placeholder="Nairobi - Nakuru" required>
                </label>
                <label for="passengers">Passengers
                    <input id="passengers" name="passengers" type="number" min="1" placeholder="8" required>
                </label>
                <label for="date">Travel Date
                    <input id="date" name="date" type="date" required>
                </label>
                <button type="submit">Submit Request</button>
            </form>
        </div>

        <div class="panel">
            <h2>Recent Requests</h2>
            <% if (((java.util.List<?>) request.getAttribute("requests")) == null || ((java.util.List<?>) request.getAttribute("requests")).isEmpty()) { %>
                <p class="empty">No requests have been submitted yet.</p>
            <% } else { %>
                <table>
                    <thead>
                    <tr>
                        <th>ID</th>
                        <th>Purpose</th>
                        <th>Passengers</th>
                        <th>Destination</th>
                        <th>Date</th>
                        <th>Status</th>
                    </tr>
                    </thead>
                    <tbody>
                    <% for (com.staff.model.Request item : (java.util.List<com.staff.model.Request>) request.getAttribute("requests")) { %>
                        <tr>
                            <td><%= item.getId() %></td>
                            <td><%= item.getDriver() %></td>
                            <td><%= item.getDriverInitials() %></td>
                            <td><%= item.getDestination() %></td>
                            <td><%= item.getDate() %></td>
                            <td><span class="status"><%= item.getStatus() %></span></td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            <% } %>
        </div>
    </section>
</div>
</body>
</html>
