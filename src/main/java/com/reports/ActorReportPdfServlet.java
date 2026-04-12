package com.reports;

import com.transportmanager.dao.TripDAO;
import com.transportmanager.util.DbUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.pdmodel.font.PDType1Font;
import org.apache.pdfbox.pdmodel.font.Standard14Fonts;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@WebServlet(name = "ActorReportPdfServlet", urlPatterns = {
        "/staff/reports/pdf",
        "/driver/reports/pdf",
        "/dean/reports/pdf",
        "/manager/reports/pdf"
})
public class ActorReportPdfServlet extends HttpServlet {

    private static final PDType1Font FONT_BOLD = new PDType1Font(Standard14Fonts.FontName.HELVETICA_BOLD);
    private static final PDType1Font FONT_REGULAR = new PDType1Font(Standard14Fonts.FontName.HELVETICA);
    private static final DateTimeFormatter DT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    private transient TripDAO tripDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        this.tripDAO = new TripDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = String.valueOf(session.getAttribute("userRole"));
        String uri = request.getRequestURI();

        if (uri.endsWith("/staff/reports/pdf") && "STAFF".equals(role)) {
            exportStaffPdf(response, String.valueOf(session.getAttribute("username")));
            return;
        }
        if (uri.endsWith("/driver/reports/pdf") && "DRIVER".equals(role)) {
            exportDriverPdf(request, response, String.valueOf(session.getAttribute("username")));
            return;
        }
        if (uri.endsWith("/dean/reports/pdf") && "DEAN".equals(role)) {
            exportDeanPdf(response);
            return;
        }
        if (uri.endsWith("/manager/reports/pdf") && "TRANSPORT_MANAGER".equals(role)) {
            exportManagerPdf(request, response);
            return;
        }

        response.sendError(HttpServletResponse.SC_FORBIDDEN, "You are not allowed to export this report.");
    }

    private void exportStaffPdf(HttpServletResponse response, String username) throws IOException {
        List<String> rows = new ArrayList<>();
        int total = 0;
        int pending = 0;
        int approved = 0;
        int rejected = 0;

        String sql = """
            SELECT tr.id,
                   tr.destination,
                   tr.requesting_department,
                   tr.passenger_count,
                   tr.status,
                   tr.manager_note,
                   tr.departure_time
            FROM trip_request tr
            INNER JOIN users u ON u.id = tr.requester_id
            WHERE u.username = ?
            ORDER BY tr.created_at DESC
            LIMIT 200
        """;

        try (Connection connection = DbUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, username == null ? "" : username.trim().toLowerCase());
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    total++;
                    String status = safe(rs.getString("status"));
                    if ("REQUESTED".equalsIgnoreCase(status) || "SCHEDULED".equalsIgnoreCase(status) || "SUBMITTED".equalsIgnoreCase(status)) {
                        pending++;
                    } else if ("REJECTED".equalsIgnoreCase(status) || "CANCELLED".equalsIgnoreCase(status)) {
                        rejected++;
                    } else {
                        approved++;
                    }

                    rows.add(rs.getLong("id")
                            + " | " + safe(rs.getString("destination"))
                            + " | " + safe(rs.getString("requesting_department"))
                            + " | Pax " + rs.getInt("passenger_count")
                            + " | " + status
                            + " | " + safe(shorten(rs.getString("manager_note"), 35))
                            + " | " + formatTimestamp(rs.getTimestamp("departure_time")));
                }
            }
        } catch (SQLException ex) {
            rows.clear();
            rows.add("Could not read staff report data.");
        }

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=ATMS_Staff_Report.pdf");

        try (PDDocument document = new PDDocument()) {
            PDPage page = new PDPage(PDRectangle.A4);
            document.addPage(page);
            try (PDPageContentStream cs = new PDPageContentStream(document, page)) {
                float y = drawHeader(cs, "ATMS Staff Trip Request Report", "Detailed request history and outcomes");
                y = writeLine(cs, y, "Staff Username: " + username, 11, false);
                y = writeLine(cs, y, "Generated At: " + LocalDateTime.now().format(DT), 11, false);
                y = writeLine(cs, y, "Total: " + total + " | Pending: " + pending + " | Approved/Confirmed: " + approved + " | Rejected/Cancelled: " + rejected, 11, true);
                y -= 4;
                y = writeLine(cs, y, "Request ID | Destination | Department | Pax | Status | Manager Note | Departure", 10, true);
                for (String row : rows) {
                    if (y < 72) {
                        break;
                    }
                    y = writeLine(cs, y, row, 9, false);
                }
            }
            document.save(response.getOutputStream());
        }
    }

    private void exportDriverPdf(HttpServletRequest request, HttpServletResponse response, String username) throws IOException {
        LocalDate startDate = parseDateOrDefault(request.getParameter("startDate"), LocalDate.now().withDayOfMonth(1));
        LocalDate endDate = parseDateOrDefault(request.getParameter("endDate"), LocalDate.now());
        if (startDate.isAfter(endDate)) {
            LocalDate tmp = startDate;
            startDate = endDate;
            endDate = tmp;
        }

        Map<String, Object> summary = tripDAO.getDriverReportSummary(startDate, endDate, username);
        List<String> rows = loadDriverTripRows(username, startDate, endDate);
        List<String> logRows = loadDriverLogRows(username, startDate, endDate);

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=ATMS_Driver_Report.pdf");

        try (PDDocument document = new PDDocument()) {
            PDPage page = new PDPage(PDRectangle.A4);
            document.addPage(page);
            try (PDPageContentStream cs = new PDPageContentStream(document, page)) {
                float y = drawHeader(cs, "ATMS Driver Assignment Report", "Detailed assigned trips and operational outcomes");
                y = writeLine(cs, y, "Driver Username: " + username, 11, false);
                y = writeLine(cs, y, "Period: " + startDate + " to " + endDate, 11, false);
                y = writeLine(cs, y, "Assigned Trips: " + summary.getOrDefault("totalAssignedTrips", 0)
                        + " | Active: " + summary.getOrDefault("activeAssignments", 0)
                        + " | Overrides: " + summary.getOrDefault("overriddenAssignments", 0)
                        + " | Passengers: " + summary.getOrDefault("passengersHandled", 0), 11, true);
                y -= 4;
                y = writeLine(cs, y, "Trip ID | Destination | Departure | Pax | Assignment Status | Override", 10, true);
                for (String row : rows) {
                    if (y < 72) {
                        break;
                    }
                    y = writeLine(cs, y, row, 9, false);
                }
                y -= 2;
                if (y >= 90) {
                    y = writeLine(cs, y, "Driver Operational Logs (Type | Start | End | Notes)", 10, true);
                    for (String row : logRows) {
                        if (y < 72) {
                            break;
                        }
                        y = writeLine(cs, y, row, 9, false);
                    }
                }
            }
            document.save(response.getOutputStream());
        }
    }

    private void exportDeanPdf(HttpServletResponse response) throws IOException {
        List<String> rows = new ArrayList<>();
        int pending = 0;
        int approved = 0;
        int rejected = 0;

        String sql = """
            SELECT tr.id,
                   COALESCE(tr.destination, '-') AS destination,
                   DATE(tr.departure_time) AS travel_date,
                   tr.passenger_count,
                   tr.status,
                   COALESCE(u.full_name, u.username, 'Unknown') AS requester
            FROM trip_request tr
            LEFT JOIN users u ON u.id = tr.requester_id
            WHERE (
                COALESCE(tr.manager_note, '') ILIKE '%club%'
                OR COALESCE(tr.destination, '') ILIKE 'club:%'
            )
            ORDER BY tr.created_at DESC
            LIMIT 200
        """;

        try (Connection connection = DbUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet rs = statement.executeQuery()) {
            while (rs.next()) {
                String status = safe(rs.getString("status"));
                if ("PENDING".equalsIgnoreCase(status)) {
                    pending++;
                } else if ("REJECTED".equalsIgnoreCase(status) || "CANCELLED".equalsIgnoreCase(status)) {
                    rejected++;
                } else {
                    approved++;
                }

                rows.add(rs.getLong("id")
                        + " | " + safe(rs.getString("requester"))
                        + " | " + safe(rs.getString("destination"))
                        + " | " + rs.getDate("travel_date")
                        + " | Pax " + rs.getInt("passenger_count")
                        + " | " + status);
            }
        } catch (SQLException ex) {
            rows.clear();
            rows.add("Could not fetch dean report data.");
        }

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=ATMS_Dean_Trips.pdf");

        try (PDDocument document = new PDDocument()) {
            PDPage page = new PDPage(PDRectangle.A4);
            document.addPage(page);
            try (PDPageContentStream cs = new PDPageContentStream(document, page)) {
                float y = drawHeader(cs, "ATMS Dean Club Trips Report", "Detailed club-trip oversight summary");
                y = writeLine(cs, y, "Pending: " + pending + " | Approved/Assigned: " + approved + " | Rejected/Cancelled: " + rejected, 11, true);
                y -= 4;
                y = writeLine(cs, y, "Trip ID | Requester | Destination | Date | Pax | Status", 10, true);
                for (String row : rows) {
                    if (y < 72) {
                        break;
                    }
                    y = writeLine(cs, y, row, 9, false);
                }
            }
            document.save(response.getOutputStream());
        }
    }

    private void exportManagerPdf(HttpServletRequest request, HttpServletResponse response) throws IOException {
        LocalDate startDate = parseDateOrDefault(request.getParameter("startDate"), LocalDate.now().withDayOfMonth(1));
        LocalDate endDate = parseDateOrDefault(request.getParameter("endDate"), LocalDate.now());
        if (startDate.isAfter(endDate)) {
            LocalDate tmp = startDate;
            startDate = endDate;
            endDate = tmp;
        }

        Map<String, Object> summary = tripDAO.getManagerReportSummary(startDate, endDate);
        List<String> rows = loadManagerRows(startDate, endDate);

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=ATMS_Manager_Report.pdf");

        try (PDDocument document = new PDDocument()) {
            PDPage page = new PDPage(PDRectangle.A4);
            document.addPage(page);
            try (PDPageContentStream cs = new PDPageContentStream(document, page)) {
                float y = drawHeader(cs, "ATMS Transport Manager Report", "Detailed request handling and allocations");
                y = writeLine(cs, y, "Period: " + startDate + " to " + endDate, 11, false);
                y = writeLine(cs, y, "Requests: " + summary.getOrDefault("totalRequests", 0)
                        + " | Assigned: " + summary.getOrDefault("assignedRequests", 0)
                        + " | Open: " + summary.getOrDefault("openRequests", 0)
                        + " | Rejected: " + summary.getOrDefault("rejectedRequests", 0), 11, true);
                y = writeLine(cs, y, "Passengers: " + summary.getOrDefault("totalPassengers", 0)
                        + " | Allocations: " + summary.getOrDefault("totalAllocations", 0)
                        + " | Soft Overrides: " + summary.getOrDefault("overrideAllocations", 0), 11, true);
                y -= 4;
                y = writeLine(cs, y, "Request ID | Requester | Dept | Destination | Status | Vehicle | Driver", 10, true);
                for (String row : rows) {
                    if (y < 72) {
                        break;
                    }
                    y = writeLine(cs, y, row, 9, false);
                }
            }
            document.save(response.getOutputStream());
        }
    }

    private List<String> loadDriverTripRows(String username, LocalDate start, LocalDate end) {
        List<String> rows = new ArrayList<>();
        String sql = """
            SELECT tr.id,
                   tr.destination,
                   tr.departure_time,
                   tr.passenger_count,
                   ta.status,
                   ta.override_used
            FROM trip_assignment ta
            INNER JOIN users d ON d.id = ta.driver_id
            INNER JOIN trip_request tr ON tr.id = ta.trip_request_id
            WHERE d.username = ?
              AND DATE(COALESCE(ta.assigned_at, ta.created_at)) BETWEEN ? AND ?
            ORDER BY COALESCE(tr.departure_time, ta.created_at) DESC
            LIMIT 200
        """;

        try (Connection connection = DbUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, username == null ? "" : username.trim().toLowerCase());
            statement.setDate(2, java.sql.Date.valueOf(start));
            statement.setDate(3, java.sql.Date.valueOf(end));
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    rows.add(rs.getLong("id")
                            + " | " + safe(rs.getString("destination"))
                            + " | " + formatTimestamp(rs.getTimestamp("departure_time"))
                            + " | Pax " + rs.getInt("passenger_count")
                            + " | " + safe(rs.getString("status"))
                            + " | " + (rs.getBoolean("override_used") ? "YES" : "NO"));
                }
            }
        } catch (SQLException ex) {
            rows.add("Could not fetch detailed driver trips.");
        }

        return rows;
    }

    private List<String> loadDriverLogRows(String username, LocalDate start, LocalDate end) {
        List<String> rows = new ArrayList<>();
        String sql = """
            SELECT dtl.trip_request_id,
                   COALESCE(tr.destination, '-') AS destination,
                   COALESCE(dtl.report_type, 'OTHER') AS report_type,
                   dtl.start_time,
                   dtl.end_time,
                   COALESCE(dtl.report_notes, '-') AS report_notes
            FROM driver_trip_log dtl
            INNER JOIN users d ON d.id = dtl.driver_id
            LEFT JOIN trip_request tr ON tr.id = dtl.trip_request_id
            WHERE d.username = ?
              AND DATE(COALESCE(dtl.start_time, dtl.end_time, dtl.created_at)) BETWEEN ? AND ?
            ORDER BY dtl.created_at DESC
            LIMIT 120
        """;

        try (Connection connection = DbUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, username == null ? "" : username.trim().toLowerCase());
            statement.setDate(2, java.sql.Date.valueOf(start));
            statement.setDate(3, java.sql.Date.valueOf(end));
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    rows.add("Trip " + rs.getLong("trip_request_id")
                            + " | " + safe(rs.getString("report_type"))
                            + " | " + formatTimestamp(rs.getTimestamp("start_time"))
                            + " | " + formatTimestamp(rs.getTimestamp("end_time"))
                            + " | " + safe(shorten(rs.getString("report_notes"), 36))
                            + " | " + safe(shorten(rs.getString("destination"), 16)));
                }
            }
        } catch (SQLException ex) {
            rows.add("Could not fetch driver operational logs.");
        }

        if (rows.isEmpty()) {
            rows.add("No driver logs in selected period.");
        }
        return rows;
    }

    private List<String> loadManagerRows(LocalDate start, LocalDate end) {
        List<String> rows = new ArrayList<>();
        String sql = """
            SELECT tr.id,
                   COALESCE(u.full_name, u.username, '-') AS requester,
                   COALESCE(tr.requesting_department, '-') AS department,
                   COALESCE(tr.destination, '-') AS destination,
                   COALESCE(tr.status, '-') AS status,
                   COALESCE(v.plate_number, '-') AS vehicle,
                   COALESCE(d.full_name, '-') AS driver
            FROM trip_request tr
            LEFT JOIN users u ON u.id = tr.requester_id
            LEFT JOIN LATERAL (
                SELECT *
                FROM trip_assignment ta
                WHERE ta.trip_request_id = tr.id
                ORDER BY ta.id DESC
                LIMIT 1
            ) ta ON TRUE
            LEFT JOIN vehicle v ON v.id = ta.vehicle_id
            LEFT JOIN users d ON d.id = ta.driver_id
            WHERE DATE(COALESCE(tr.departure_time, tr.created_at)) BETWEEN ? AND ?
            ORDER BY tr.created_at DESC
            LIMIT 250
        """;

        try (Connection connection = DbUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setDate(1, java.sql.Date.valueOf(start));
            statement.setDate(2, java.sql.Date.valueOf(end));
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    rows.add(rs.getLong("id")
                            + " | " + safe(rs.getString("requester"))
                            + " | " + safe(rs.getString("department"))
                            + " | " + safe(shorten(rs.getString("destination"), 20))
                            + " | " + safe(rs.getString("status"))
                            + " | " + safe(rs.getString("vehicle"))
                            + " | " + safe(rs.getString("driver")));
                }
            }
        } catch (SQLException ex) {
            rows.add("Could not fetch detailed manager rows.");
        }

        return rows;
    }

    private float drawHeader(PDPageContentStream cs, String title, String subtitle) throws IOException {
        setNonStrokeRgb(cs, 6, 78, 59);
        cs.addRect(40, 780, 515, 40);
        cs.fill();
        setNonStrokeRgb(cs, 255, 255, 255);
        cs.beginText();
        cs.setFont(FONT_BOLD, 14);
        cs.newLineAtOffset(50, 796);
        cs.showText("ATMS");
        cs.endText();

        float y = 748;
        setNonStrokeRgb(cs, 12, 30, 66);
        y = writeLine(cs, y, title, 16, true);
        y = writeLine(cs, y, subtitle, 11, false);
        return y - 8;
    }

    private float writeLine(PDPageContentStream cs, float y, String text, int size, boolean bold) throws IOException {
        setNonStrokeRgb(cs, 17, 24, 39);
        cs.beginText();
        cs.setFont(bold ? FONT_BOLD : FONT_REGULAR, size);
        cs.newLineAtOffset(50, y);
        cs.showText(sanitize(text));
        cs.endText();
        return y - (size + 6);
    }

    private LocalDate parseDateOrDefault(String raw, LocalDate fallback) {
        if (raw == null || raw.isBlank()) {
            return fallback;
        }
        try {
            return LocalDate.parse(raw.trim());
        } catch (Exception ex) {
            return fallback;
        }
    }

    private String sanitize(String text) {
        if (text == null) {
            return "";
        }
        return text.replace('\n', ' ').replace('\r', ' ').trim();
    }

    private String safe(String text) {
        if (text == null || text.isBlank()) {
            return "-";
        }
        return text.trim();
    }

    private String shorten(String text, int maxLen) {
        String value = safe(text);
        if (value.length() <= maxLen) {
            return value;
        }
        return value.substring(0, Math.max(0, maxLen - 3)) + "...";
    }

    private String formatTimestamp(Timestamp timestamp) {
        if (timestamp == null) {
            return "-";
        }
        return timestamp.toLocalDateTime().format(DT);
    }

    private void setNonStrokeRgb(PDPageContentStream cs, int r, int g, int b) throws IOException {
        cs.setNonStrokingColor(normalizeColor(r), normalizeColor(g), normalizeColor(b));
    }

    private float normalizeColor(int value) {
        int clamped = Math.max(0, Math.min(255, value));
        return clamped / 255f;
    }
}
