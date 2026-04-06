package com.transportmanager.controller;

import com.transportmanager.dao.TripDAO;
import com.transportmanager.model.Trip;
import com.transportmanager.util.ManagerSessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.Collections;
import java.util.List;

@WebServlet(name = "PendingTripQueueServlet", urlPatterns = {"/manager/trips/pending"})
public class PendingTripQueueServlet extends HttpServlet {
    private static final String PENDING_TRIPS_JSP = "/WEB-INF/manager/pendingTripQueue.jsp";

    // DAO Means a Data Access Object- responsible for communicating with db
    private transient TripDAO tripDAO;

    @Override//this helps capture signature mistakes
    public void init() throws ServletException {
        super.init();
        // Simple initialization. In bigger projects, use dependency injection.
        this.tripDAO = new TripDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        // 1) Authorization check: only transport manager can access this endpoint.
        if (!ManagerSessionUtil.isManagerLoggedIn(request)) {
            ManagerSessionUtil.redirectToLogin(request, response);
            return;
        }

        // 2) Read and defensively validate optional filter parameters.
        int page = parsePositiveIntOrDefault(request.getParameter("page"), 1);
        int size = parseRangeIntOrDefault(request.getParameter("size"), 10, 1, 100);

        String priority = sanitizePriority(request.getParameter("priority"));
        LocalDate dateFrom = parseDateOrNull(request.getParameter("dateFrom"));
        LocalDate dateTo = parseDateOrNull(request.getParameter("dateTo"));

        //  validation rule: dateFrom must not be after dateTo.
        if (dateFrom != null && dateTo != null && dateFrom.isAfter(dateTo)) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "dateFrom cannot be after dateTo.");
            return;
        }

        List<Trip> pendingTrips;
        try {
            // 3) Fetch priority-sorted pending trips from DAO.
            pendingTrips = tripDAO.findPendingTripsSorted(page, size, priority, dateFrom, dateTo);
        } catch (Exception ex) {
            // Hide internal details from client.
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Failed to load pending trips.");
            return;
        }

        if (pendingTrips == null) {
            pendingTrips = Collections.emptyList();
        }

        // 4) Send data to JSP for rendering.
        request.setAttribute("pendingTrips", pendingTrips);
        request.setAttribute("page", page);
        request.setAttribute("size", size);
        request.setAttribute("priority", priority);
        request.setAttribute("dateFrom", dateFrom);
        request.setAttribute("dateTo", dateTo);

        request.getRequestDispatcher(PENDING_TRIPS_JSP).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // Viewing queue is read-only, so POST is not allowed here.
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED, "Use GET for viewing pending trip queue.");
    }

    private int parsePositiveIntOrDefault(String raw, int defaultValue) {
        if (raw == null || raw.isBlank()) {
            return defaultValue;
        }
        try {
            int value = Integer.parseInt(raw.trim());
            return (value > 0) ? value : defaultValue;
        } catch (NumberFormatException ex) {
            return defaultValue;
        }
    }

    private int parseRangeIntOrDefault(String raw, int defaultValue, int min, int max) {
        int value = parsePositiveIntOrDefault(raw, defaultValue);
        if (value < min || value > max) {
            return defaultValue;
        }
        return value;
    }

    private LocalDate parseDateOrNull(String raw) {
        if (raw == null || raw.isBlank()) {
            return null;
        }
        try {
            return LocalDate.parse(raw.trim());
        } catch (DateTimeParseException ex) {
            return null;
        }
    }

    private String sanitizePriority(String raw) {
        if (raw == null || raw.isBlank()) {
            return null;
        }
        String value = raw.trim().toUpperCase();
        if ("HIGH".equals(value) || "MEDIUM".equals(value) || "LOW".equals(value)) {
            return value;
        }
        return null;
    }

}