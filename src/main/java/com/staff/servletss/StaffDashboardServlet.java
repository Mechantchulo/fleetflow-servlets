package com.staff.servletss;

import com.staff.dao.StaffTripDAO;
import com.staff.model.Request;
import com.transportmanager.util.ValidationUtil;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession; 
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.math.BigDecimal;
import java.io.InputStream;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;

@WebServlet("/staff/dashboard") // 1. Updated standard URL
@MultipartConfig(maxFileSize = 8 * 1024 * 1024, maxRequestSize = 10 * 1024 * 1024)
public class StaffDashboardServlet extends HttpServlet {

    private transient StaffTripDAO staffTripDAO;

    @Override
    public void init() {
        this.staffTripDAO = new StaffTripDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 2. SECURITY CHECK: Bounce them if they aren't logged in as STAFF
        HttpSession session = request.getSession(false);
        if (session == null || !"STAFF".equals(session.getAttribute("userRole"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String staffUsername = String.valueOf(session.getAttribute("username"));
        List<Request> requests = staffTripDAO.findRequestsByStaff(staffUsername);
        String staffDepartment = staffTripDAO.findDepartmentByUsername(staffUsername);

        int totalRequests = requests.size();
        int approved = (int) requests.stream()
                .filter(r -> "Approved".equalsIgnoreCase(r.getStatus()))
                .count();
        int pending = (int) requests.stream()
                .filter(r -> "Pending".equalsIgnoreCase(r.getStatus()))
                .count();

        // Send data to JSP
        request.setAttribute("totalRequests", totalRequests);
        request.setAttribute("approvedRequests", approved);
        request.setAttribute("pendingRequests", pending);
        request.setAttribute("requests", requests);
        request.setAttribute("staffDepartment", staffDepartment);

        // 3. SECURE JSP PATH: Forwarding into the WEB-INF folder
        request.getRequestDispatcher("/WEB-INF/staff/staffDashboard.jsp").forward(request, response);
    }

    // Handle form submission (New Bus Request)
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 2. SECURITY CHECK: Protect the form submission too!
        HttpSession session = request.getSession(false);
        if (session == null || !"STAFF".equals(session.getAttribute("userRole"))) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "You must be logged in as Staff to submit requests.");
            return;
        }

        String destination = trimToEmpty(request.getParameter("destination"));
        String date = trimToEmpty(request.getParameter("date"));
        String passengersRaw = trimToEmpty(request.getParameter("passengers"));
        String purpose = trimToEmpty(request.getParameter("purpose"));
        String budgetRaw = trimToEmpty(request.getParameter("requestedBudget"));
        String department = trimToEmpty(request.getParameter("department"));

        LocalDate preferredDate;
        try {
            preferredDate = LocalDate.parse(date);
        } catch (DateTimeParseException ex) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid date format.");
            return;
        }

        if (preferredDate.isBefore(LocalDate.now())) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Preferred date cannot be in the past.");
            return;
        }

        if (destination.isBlank()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Destination is required.");
            return;
        }
        String staffUsername = (String) session.getAttribute("username");
        if (department.isBlank()) {
            department = trimToEmpty(staffTripDAO.findDepartmentByUsername(staffUsername));
        }
        if (department.isBlank()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Department is required.");
            return;
        }
        if (!ValidationUtil.isAlphabeticWithSpaces(department)) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Department must contain letters and spaces only.");
            return;
        }

        int passengers;
        try {
            passengers = Integer.parseInt(passengersRaw);
        } catch (NumberFormatException ex) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Passengers must be a number.");
            return;
        }

        if (passengers < 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Passengers cannot be negative.");
            return;
        }

        BigDecimal requestedBudget;
        try {
            requestedBudget = budgetRaw.isBlank() ? BigDecimal.ZERO : new BigDecimal(budgetRaw);
        } catch (NumberFormatException ex) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Requested budget must be a valid amount.");
            return;
        }
        if (requestedBudget.signum() < 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Requested budget cannot be negative.");
            return;
        }

        String documentName = null;
        String documentMimeType = null;
        byte[] documentData = null;
        try {
            Part documentPart = request.getPart("scheduleDocument");
            if (documentPart != null && documentPart.getSize() > 0) {
                documentName = extractFileName(documentPart);
                documentMimeType = documentPart.getContentType();
                if (documentMimeType == null || !documentMimeType.toLowerCase().contains("pdf")) {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Only PDF documents are allowed.");
                    return;
                }
                if (documentPart.getSize() > 8 * 1024 * 1024) {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "PDF must be 8MB or smaller.");
                    return;
                }
                try (InputStream in = documentPart.getInputStream()) {
                    documentData = in.readAllBytes();
                }
            }
        } catch (ServletException ex) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid uploaded document.");
            return;
        }

        boolean saved = staffTripDAO.createStaffRequest(
                staffUsername,
                destination,
                preferredDate,
                passengers,
                purpose,
                requestedBudget,
                department,
                documentName,
                documentMimeType,
                documentData
        );
        if (!saved) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Failed to submit request to timetabling.");
            return;
        }

        // Redirect safely back to the dashboard (PRG Pattern)
        response.sendRedirect(request.getContextPath() + "/staff/dashboard");
    }

    private String trimToEmpty(String value) {
        return value == null ? "" : value.trim();
    }

    private String extractFileName(Part part) {
        String submitted = part.getSubmittedFileName();
        if (submitted == null || submitted.isBlank()) {
            return "staff-request.pdf";
        }
        return submitted.replace("\\", "/").replaceAll("^.*/", "");
    }
}
