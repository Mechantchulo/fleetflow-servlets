package com.driver.driverdashboard;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/driver/dashboard") // 1. Standard URL Routing
public class DriverDashboardServlet extends HttpServlet {

    @Override
    @SuppressWarnings("unchecked")
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 2. SECURITY CHECK: Bounce unauthorized users
        HttpSession session = request.getSession(false);
        if (session == null || !"DRIVER".equals(session.getAttribute("userRole"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 3. GET DATA (Replacing your broken getSessionAttribute method)
        List<Trip> trips = (List<Trip>) session.getAttribute("trips");

        if (trips == null) {
            trips = new ArrayList<>();
            session.setAttribute("trips", trips);
        }

        // Pass the data to the request so the JSP can see it
        request.setAttribute("trips", trips);

        // 4. FORWARD TO JSP: No more PrintWriter!
        request.getRequestDispatcher("/WEB-INF/driver/dashboard.jsp").forward(request, response);
    }

    @Override
    @SuppressWarnings("unchecked")
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Security check for the form submission
        HttpSession session = request.getSession(false);
        if (session == null || !"DRIVER".equals(session.getAttribute("userRole"))) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "You must be logged in as a Driver.");
            return;
        }

        String destination = request.getParameter("destination");
        String date = request.getParameter("date");
        String passengersStr = request.getParameter("passengers");

        // Basic Validation
        if (destination != null && !destination.isEmpty() && date != null && passengersStr != null) {
            try {
                int passengers = Integer.parseInt(passengersStr);
                
                if (passengers > 0 && passengers <= 100) {
                    java.time.LocalDate selectedDate = java.time.LocalDate.parse(date);
                    java.time.LocalDate today = java.time.LocalDate.now();

                    if (!selectedDate.isBefore(today)) {
                        // Validation passed! Create Trip object
                        String id = "TP-" + (int) (Math.random() * 1000);
                        Trip trip = new Trip(id, destination, date, passengers);

                        List<Trip> trips = (List<Trip>) session.getAttribute("trips");
                        if (trips == null) {
                            trips = new ArrayList<>();
                        }
                        trips.add(trip);
                        session.setAttribute("trips", trips);
                    } else {
                        session.setAttribute("error", "Date cannot be in the past.");
                    }
                } else {
                    session.setAttribute("error", "Passengers must be between 1 and 100.");
                }
            } catch (Exception e) {
                session.setAttribute("error", "Invalid input format.");
            }
        } else {
            session.setAttribute("error", "All fields are required.");
        }

        // PRG Pattern: Redirect back to the GET method safely
        response.sendRedirect(request.getContextPath() + "/driver/dashboard");
    }
}