package com.staff.servletss;

import com.staff.dao.StaffTripDAO;
import com.staff.dao.StaffTripDAO.RequestDocument;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "StaffRequestDocumentServlet", urlPatterns = {"/staff/requests/document"})
public class StaffRequestDocumentServlet extends HttpServlet {

    private transient StaffTripDAO staffTripDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        this.staffTripDAO = new StaffTripDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = String.valueOf(session.getAttribute("userRole"));
        if (!("STAFF".equals(role) || "TIMETABLING_STAFF".equals(role) || "TRANSPORT_MANAGER".equals(role))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Not allowed.");
            return;
        }

        long requestId = parseLong(request.getParameter("id"));
        if (requestId <= 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing request id.");
            return;
        }

        RequestDocument document = staffTripDAO.findRequestDocument(requestId);
        if (document == null || document.getData() == null || document.getData().length == 0) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "No document found for this request.");
            return;
        }

        if ("STAFF".equals(role)) {
            String username = String.valueOf(session.getAttribute("username"));
            Long staffId = staffTripDAO.findUserIdByUsername(username);
            if (staffId == null || staffId.longValue() != document.getRequesterId()) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "You can only view your own request document.");
                return;
            }
        }

        String fileName = document.getFileName() == null || document.getFileName().isBlank()
                ? "request-" + requestId + ".pdf"
                : document.getFileName();
        String contentType = document.getContentType();
        if (contentType == null || contentType.isBlank()) {
            contentType = "application/pdf";
        }

        response.setContentType(contentType);
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName.replace('"', '_') + "\"");
        response.getOutputStream().write(document.getData());
        response.getOutputStream().flush();
    }

    private long parseLong(String raw) {
        if (raw == null || raw.isBlank()) {
            return -1L;
        }
        try {
            return Long.parseLong(raw.trim());
        } catch (NumberFormatException ex) {
            return -1L;
        }
    }
}
