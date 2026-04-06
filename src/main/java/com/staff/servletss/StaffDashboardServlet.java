package com.staff.servletss;

import com.staff.model.Request;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.ServletException;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/dashboard")
public class StaffDashboardServlet extends HttpServlet {

    // Simulated database
    private static List<Request> requests = new ArrayList<>();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Calculate stats
        int totalRequests = requests.size();
        int approved = (int) requests.stream().filter(r -> r.getStatus().equals("Approved")).count();
        int pending = (int) requests.stream().filter(r -> r.getStatus().equals("Pending")).count();

        // Send data to JSP
        request.setAttribute("totalRequests", totalRequests);
        request.setAttribute("approvedRequests", approved);
        request.setAttribute("pendingRequests", pending);
        request.setAttribute("requests", requests);

        // Navigate to JSP
        request.getRequestDispatcher("/staff/dashboard.jsp").forward(request, response);
    }

    // Handle form submission (New Bus Request)
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String purpose = request.getParameter("purpose");
        String destination = request.getParameter("destination");
        String passengers = request.getParameter("passengers");
        String date = request.getParameter("date");

        // Create request object
        String passengerInitials = passengers == null || passengers.isBlank() ? "N/A" : passengers + " pax";
        Request req = new Request(requests.size() + 1, purpose, passengerInitials, destination, date, "Pending");

        requests.add(req);

        // Redirect (avoid form resubmission)
        response.sendRedirect("dashboard");
    }
}
