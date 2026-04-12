package com.driver.driverdashboard;

import com.transportmanager.util.DbUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/driver/dashboard")
public class DriverDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !"DRIVER".equals(session.getAttribute("userRole"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String username = String.valueOf(session.getAttribute("username"));
        List<Trip> trips = findAssignedTrips(username);
        List<DriverTripLog> logs = findDriverTripLogs(username, 100);
        request.setAttribute("trips", trips);
        request.setAttribute("logs", logs);
        request.getRequestDispatcher("/WEB-INF/driver/driverDashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !"DRIVER".equals(session.getAttribute("userRole"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String username = String.valueOf(session.getAttribute("username"));
        long tripRequestId = parsePositiveLongOrDefault(request.getParameter("tripRequestId"), -1L);
        String reportType = normalizeReportType(request.getParameter("reportType"));
        String notes = trimToEmpty(request.getParameter("reportNotes"));
        String startTimeRaw = trimToEmpty(request.getParameter("startTime"));
        String endTimeRaw = trimToEmpty(request.getParameter("endTime"));

        if (tripRequestId <= 0) {
            session.setAttribute("error", "Please select a valid trip.");
            response.sendRedirect(request.getContextPath() + "/driver/dashboard");
            return;
        }

        LocalDateTime startTime = null;
        LocalDateTime endTime = null;
        try {
            if (!startTimeRaw.isBlank()) {
                startTime = LocalDateTime.parse(startTimeRaw);
            }
            if (!endTimeRaw.isBlank()) {
                endTime = LocalDateTime.parse(endTimeRaw);
            }
        } catch (DateTimeParseException ex) {
            session.setAttribute("error", "Invalid start/end time format.");
            response.sendRedirect(request.getContextPath() + "/driver/dashboard");
            return;
        }

        if (startTime != null && endTime != null && endTime.isBefore(startTime)) {
            session.setAttribute("error", "End time cannot be before start time.");
            response.sendRedirect(request.getContextPath() + "/driver/dashboard");
            return;
        }

        if (startTime == null && endTime == null && notes.isBlank()) {
            session.setAttribute("error", "Add at least start/end time or report notes.");
            response.sendRedirect(request.getContextPath() + "/driver/dashboard");
            return;
        }

        boolean saved = saveDriverTripLog(username, tripRequestId, reportType, startTime, endTime, notes);
        if (!saved) {
            session.setAttribute("error", "Could not save trip log. Confirm trip is assigned to you.");
        }

        response.sendRedirect(request.getContextPath() + "/driver/dashboard");
    }

    private List<Trip> findAssignedTrips(String username) {
        List<Trip> trips = new ArrayList<>();
        if (username == null || username.isBlank()) {
            return trips;
        }

        String sql = """
            SELECT tr.id,
                   tr.destination,
                   tr.departure_time,
                   tr.passenger_count
            FROM trip_assignment ta
            INNER JOIN trip_request tr ON tr.id = ta.trip_request_id
            INNER JOIN users d ON d.id = ta.driver_id
            WHERE d.username = ?
              AND ta.status = 'ASSIGNED'
            ORDER BY tr.departure_time ASC NULLS LAST
        """;

        try (Connection connection = DbUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, username.trim().toLowerCase());
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    Trip trip = new Trip();
                    trip.setId(String.valueOf(rs.getLong("id")));
                    trip.setDestination(rs.getString("destination"));
                    Timestamp departure = rs.getTimestamp("departure_time");
                    LocalDate date = departure == null ? null : departure.toLocalDateTime().toLocalDate();
                    trip.setDate(date == null ? "-" : date.toString());
                    trip.setPassengers(rs.getInt("passenger_count"));
                    trips.add(trip);
                }
            }
        } catch (SQLException ex) {
            return new ArrayList<>();
        }

        return trips;
    }

    private List<DriverTripLog> findDriverTripLogs(String username, int limit) {
        List<DriverTripLog> logs = new ArrayList<>();
        if (username == null || username.isBlank()) {
            return logs;
        }

        String sql = """
            SELECT dtl.id,
                   dtl.trip_request_id,
                   tr.destination,
                   dtl.report_type,
                   dtl.start_time,
                   dtl.end_time,
                   dtl.report_notes,
                   dtl.created_at
            FROM driver_trip_log dtl
            INNER JOIN users d ON d.id = dtl.driver_id
            LEFT JOIN trip_request tr ON tr.id = dtl.trip_request_id
            WHERE d.username = ?
            ORDER BY dtl.created_at DESC
            LIMIT ?
        """;

        try (Connection connection = DbUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, username.trim().toLowerCase());
            statement.setInt(2, Math.max(1, limit));

            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    DriverTripLog log = new DriverTripLog();
                    log.setId(rs.getLong("id"));
                    log.setTripRequestId(rs.getLong("trip_request_id"));
                    log.setDestination(rs.getString("destination"));
                    log.setReportType(rs.getString("report_type"));
                    Timestamp start = rs.getTimestamp("start_time");
                    Timestamp end = rs.getTimestamp("end_time");
                    Timestamp created = rs.getTimestamp("created_at");
                    log.setStartTime(start == null ? null : start.toLocalDateTime());
                    log.setEndTime(end == null ? null : end.toLocalDateTime());
                    log.setCreatedAt(created == null ? null : created.toLocalDateTime());
                    log.setReportNotes(rs.getString("report_notes"));
                    logs.add(log);
                }
            }
        } catch (SQLException ex) {
            return new ArrayList<>();
        }

        return logs;
    }

    private boolean saveDriverTripLog(String username,
                                      long tripRequestId,
                                      String reportType,
                                      LocalDateTime startTime,
                                      LocalDateTime endTime,
                                      String notes) {
        if (username == null || username.isBlank()) {
            return false;
        }

        String sql = """
            INSERT INTO driver_trip_log (driver_id, trip_request_id, report_type, start_time, end_time, report_notes, created_at)
            SELECT d.id, ta.trip_request_id, ?, ?, ?, ?, NOW()
            FROM users d
            INNER JOIN trip_assignment ta ON ta.driver_id = d.id
            WHERE d.username = ?
              AND ta.trip_request_id = ?
              AND ta.status = 'ASSIGNED'
            LIMIT 1
        """;

        try (Connection connection = DbUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, reportType);
            if (startTime == null) {
                statement.setNull(2, java.sql.Types.TIMESTAMP);
            } else {
                statement.setTimestamp(2, Timestamp.valueOf(startTime));
            }
            if (endTime == null) {
                statement.setNull(3, java.sql.Types.TIMESTAMP);
            } else {
                statement.setTimestamp(3, Timestamp.valueOf(endTime));
            }
            statement.setString(4, notes);
            statement.setString(5, username.trim().toLowerCase());
            statement.setLong(6, tripRequestId);
            return statement.executeUpdate() > 0;
        } catch (SQLException ex) {
            return false;
        }
    }

    private long parsePositiveLongOrDefault(String raw, long defaultValue) {
        if (raw == null || raw.isBlank()) {
            return defaultValue;
        }
        try {
            long parsed = Long.parseLong(raw.trim());
            return parsed > 0 ? parsed : defaultValue;
        } catch (NumberFormatException ex) {
            return defaultValue;
        }
    }

    private String trimToEmpty(String value) {
        return value == null ? "" : value.trim();
    }

    private String normalizeReportType(String raw) {
        String value = trimToEmpty(raw).toUpperCase();
        if ("INCIDENT".equals(value) || "MECHANICAL".equals(value) || "FUEL".equals(value)
                || "DELAY".equals(value) || "OTHER".equals(value)) {
            return value;
        }
        return "OTHER";
    }
}
