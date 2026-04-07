package com.staff.servletss;

import com.staff.model.Request;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession; 
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.ServletException;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/staff/dashboard") // 1. Updated standard URL
public class StaffDashboardServlet extends HttpServlet {

    // Simulated database
    private static List<Request> requests = new ArrayList<>();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 2. SECURITY CHECK: Bounce them if they aren't logged in as STAFF
        HttpSession session = request.getSession(false);
        if (session == null || !"STAFF".equals(session.getAttribute("userRole"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Calculate stats (Safe string comparison)
        int totalRequests = requests.size();
        int approved = (int) requests.stream().filter(r -> "Approved".equals(r.getStatus())).count();
        int pending = (int) requests.stream().filter(r -> "Pending".equals(r.getStatus())).count();

        // Send data to JSP
        request.setAttribute("totalRequests", totalRequests);
        request.setAttribute("approvedRequests", approved);
        request.setAttribute("pendingRequests", pending);
        request.setAttribute("requests", requests);

        // 3. SECURE JSP PATH: Forwarding into the WEB-INF folder
        request.getRequestDispatcher("/WEB-INF/staff/dashboard.jsp").forward(request, response);
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

        String destination = request.getParameter("destination");
        String date = request.getParameter("date");

        // 4. SMART MAPPING: Get the real username from the session
        String staffUsername = (String) session.getAttribute("username");
        String initials = (staffUsername != null && staffUsername.length() >= 2) 
                          ? staffUsername.substring(0, 2).toUpperCase() 
                          : "NA";

        // Create request object using the secure session data
        Request req = new Request(requests.size() + 1, staffUsername, initials, destination, date, "Pending");

        requests.add(req);

        // Redirect safely back to the dashboard (PRG Pattern)
        response.sendRedirect(request.getContextPath() + "/staff/dashboard");
    }
}