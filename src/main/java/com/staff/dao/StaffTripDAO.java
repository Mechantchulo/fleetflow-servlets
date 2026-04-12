package com.staff.dao;

import com.staff.model.Request;
import com.staff.model.Trip;
import com.transportmanager.util.DbUtil;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class StaffTripDAO {

    public boolean createStaffRequest(String username,
                                      String destination,
                                      LocalDate preferredDate,
                                      int passengers,
                                      String purpose,
                                      BigDecimal requestedBudget,
                                      String department,
                                      String documentName,
                                      String documentMimeType,
                                      byte[] documentData) {
        Long staffId = findUserIdByUsername(username);
        if (staffId == null) {
            return false;
        }

        String sql = """
            INSERT INTO trip_request
            (destination, departure_time, passenger_count, status, trip_type, requester_id, manager_note, planned_budget, requesting_department, document_name, document_mime_type, document_data, created_at, updated_at)
            VALUES (?, ?, ?, 'REQUESTED', 'ACADEMIC', ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())
        """;

        try (Connection connection = DbUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, destination);
            if (preferredDate == null) {
                statement.setNull(2, java.sql.Types.TIMESTAMP);
            } else {
                statement.setTimestamp(2, Timestamp.valueOf(preferredDate.atTime(8, 0)));
            }
            statement.setInt(3, Math.max(1, passengers));
            statement.setLong(4, staffId);
            statement.setString(5, purpose);
            statement.setBigDecimal(6, sanitizeBudget(requestedBudget));
            statement.setString(7, normalizeOptionalText(department));
            statement.setString(8, normalizeOptionalText(documentName));
            statement.setString(9, normalizeOptionalText(documentMimeType));
            if (documentData == null || documentData.length == 0) {
                statement.setNull(10, java.sql.Types.BINARY);
            } else {
                statement.setBytes(10, documentData);
            }
            return statement.executeUpdate() > 0;
        } catch (SQLException ex) {
            return false;
        }
    }

    public List<Request> findRequestsByStaff(String username) {
        Long staffId = findUserIdByUsername(username);
        if (staffId == null) {
            return Collections.emptyList();
        }

        String sql = """
            SELECT tr.id,
                   tr.destination,
                   tr.requesting_department,
                   DATE(tr.departure_time) AS departure_date,
                   tr.status,
                   COALESCE(u.full_name, u.username, 'Staff') AS requester_name
            FROM trip_request tr
            LEFT JOIN users u ON u.id = tr.requester_id
            WHERE tr.requester_id = ?
            ORDER BY tr.created_at DESC
        """;

        List<Request> requests = new ArrayList<>();
        try (Connection connection = DbUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, staffId);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    Request request = new Request();
                    request.setId(rs.getInt("id"));
                    request.setDestination(rs.getString("destination"));
                    request.setDepartment(rs.getString("requesting_department"));
                    Date departureDate = rs.getDate("departure_date");
                    request.setDate(departureDate == null ? "-" : departureDate.toString());
                    String requester = rs.getString("requester_name");
                    request.setDriver(requester);
                    request.setDriverInitials(initialsFromName(requester));
                    request.setStatus(normalizeRequestStatus(rs.getString("status")));
                    requests.add(request);
                }
            }
        } catch (SQLException ex) {
            return Collections.emptyList();
        }

        return requests;
    }

    public RequestDocument findRequestDocument(long requestId) {
        String sql = """
            SELECT tr.id,
                   tr.requester_id,
                   tr.document_name,
                   tr.document_mime_type,
                   tr.document_data
            FROM trip_request tr
            WHERE tr.id = ?
              AND tr.document_data IS NOT NULL
            LIMIT 1
        """;

        try (Connection connection = DbUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, requestId);
            try (ResultSet rs = statement.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                RequestDocument document = new RequestDocument();
                document.setRequestId(rs.getLong("id"));
                document.setRequesterId(rs.getLong("requester_id"));
                document.setFileName(rs.getString("document_name"));
                document.setContentType(rs.getString("document_mime_type"));
                document.setData(rs.getBytes("document_data"));
                return document;
            }
        } catch (SQLException ex) {
            return null;
        }
    }

    public Long findUserIdByUsername(String username) {
        return resolveUserIdByUsername(username);
    }

    public String findDepartmentByUsername(String username) {
        if (username == null || username.isBlank()) {
            return null;
        }
        String sql = "SELECT department FROM users WHERE username = ? LIMIT 1";
        try (Connection connection = DbUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, username.trim().toLowerCase());
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("department");
                }
            }
        } catch (SQLException ex) {
            return null;
        }
        return null;
    }

    public List<Trip> findTripHistoryByStaff(String username) {
        Long staffId = findUserIdByUsername(username);
        if (staffId == null) {
            return Collections.emptyList();
        }

        String sql = """
            SELECT tr.id,
                   DATE(COALESCE(tr.departure_time, tr.created_at)) AS trip_date,
                   COALESCE(d.full_name, 'TBD') AS driver_name,
                   tr.destination,
                   tr.status
            FROM trip_request tr
            LEFT JOIN LATERAL (
                SELECT *
                FROM trip_assignment ta
                WHERE ta.trip_request_id = tr.id
                ORDER BY ta.id DESC
                LIMIT 1
            ) ta ON TRUE
            LEFT JOIN users d ON d.id = ta.driver_id
            WHERE tr.requester_id = ?
              AND tr.status IN ('ASSIGNED', 'COMPLETED', 'CANCELLED', 'REJECTED')
            ORDER BY tr.updated_at DESC
        """;

        List<Trip> trips = new ArrayList<>();
        try (Connection connection = DbUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, staffId);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    Trip trip = new Trip();
                    trip.setId(rs.getInt("id"));
                    Date tripDate = rs.getDate("trip_date");
                    trip.setDate(tripDate == null ? "-" : tripDate.toString());
                    String driver = rs.getString("driver_name");
                    trip.setDriver(driver);
                    trip.setDriverInitials(initialsFromName(driver));
                    trip.setRoute(rs.getString("destination"));
                    trip.setDuration("-");
                    trip.setStatus(normalizeHistoryStatus(rs.getString("status")));
                    trips.add(trip);
                }
            }
        } catch (SQLException ex) {
            return Collections.emptyList();
        }

        return trips;
    }

    private Long resolveUserIdByUsername(String username) {
        if (username == null || username.isBlank()) {
            return null;
        }

        String sql = "SELECT id FROM users WHERE username = ? LIMIT 1";
        try (Connection connection = DbUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, username.trim().toLowerCase());
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    return rs.getLong("id");
                }
            }
        } catch (SQLException ex) {
            return null;
        }
        return null;
    }

    private String normalizeOptionalText(String text) {
        if (text == null) {
            return null;
        }
        String value = text.trim();
        return value.isEmpty() ? null : value;
    }

    private BigDecimal sanitizeBudget(BigDecimal budget) {
        if (budget == null || budget.signum() < 0) {
            return BigDecimal.ZERO;
        }
        return budget;
    }

    private String initialsFromName(String name) {
        if (name == null || name.isBlank()) {
            return "NA";
        }
        String[] parts = name.trim().split("\\s+");
        if (parts.length == 1) {
            String text = parts[0].toUpperCase();
            return text.substring(0, Math.min(2, text.length()));
        }
        String first = parts[0].substring(0, 1).toUpperCase();
        String second = parts[1].substring(0, 1).toUpperCase();
        return first + second;
    }

    private String normalizeRequestStatus(String status) {
        if (status == null) {
            return "Pending";
        }
        String value = status.toUpperCase();
        if ("REJECTED".equals(value) || "CANCELLED".equals(value)) {
            return "Rejected";
        }
        if ("REQUESTED".equals(value)) {
            return "Pending";
        }
        return "Approved";
    }

    private String normalizeHistoryStatus(String status) {
        if (status == null) {
            return "Completed";
        }
        String value = status.toUpperCase();
        if ("REJECTED".equals(value) || "CANCELLED".equals(value)) {
            return "Cancelled";
        }
        return "Completed";
    }

    public static class RequestDocument {
        private long requestId;
        private long requesterId;
        private String fileName;
        private String contentType;
        private byte[] data;

        public long getRequestId() {
            return requestId;
        }

        public void setRequestId(long requestId) {
            this.requestId = requestId;
        }

        public long getRequesterId() {
            return requesterId;
        }

        public void setRequesterId(long requesterId) {
            this.requesterId = requesterId;
        }

        public String getFileName() {
            return fileName;
        }

        public void setFileName(String fileName) {
            this.fileName = fileName;
        }

        public String getContentType() {
            return contentType;
        }

        public void setContentType(String contentType) {
            this.contentType = contentType;
        }

        public byte[] getData() {
            return data;
        }

        public void setData(byte[] data) {
            this.data = data;
        }
    }
}
