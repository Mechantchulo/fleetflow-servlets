package com.driver.driverdashboard;

import java.io.*;
import java.util.*;

import com.driver.driverdashboard.Trip;

import jakarta.servlet.*;
import jakarta.servlet.http.*;

public class DriverDashboardServlet extends HttpServlet {

    // DISPLAY PAGE
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession();

        // Get trips from session
        List<Trip> trips = getSessionAttribute(session, "trips");

        if (trips == null) {
            trips = new ArrayList<>();
            session.setAttribute("trips", trips);
        }

        out.println("<h2>Driver Dashboard</h2>");

        // Navigation
        out.println("<a href='FuelLogsServlet'>Fuel Logs</a> | ");
        out.println("<a href='TripLogsServlet'>Trip Logs</a><br><br>");

        // Form
        out.println("<h3>Add Trip</h3>");
        out.println("<form method='post'>");
        out.println("Destination: <input type='text' name='destination'><br><br>");
        out.println("Date: <input type='date' name='date'><br><br>");
        out.println("Passengers: <input type='number' name='passengers'><br><br>");
        out.println("<button type='submit'>Add Trip</button>");
        out.println("</form>");

        // Display Trips
        out.println("<h3>Trips</h3>");
        out.println("<table border='1'>");
        out.println("<tr><th>ID</th><th>Destination</th><th>Date</th><th>Passengers</th></tr>");

        for (Trip t : trips) {
            out.println("<tr>");
            out.println("<td>" + t.getId() + "</td>");
            out.println("<td>" + t.getDestination() + "</td>");
            out.println("<td>" + t.getDate() + "</td>");
            out.println("<td>" + t.getPassengers() + "</td>");
            out.println("</tr>");
        }

        out.println("</table>");
    }

    private List<Trip> getSessionAttribute(HttpSession session, String string) {

        throw new UnsupportedOperationException("Unimplemented method 'getSessionAttribute'");
    }

    // PROCESS FORM
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String destination = request.getParameter("destination");
        String date = request.getParameter("date");
        String passengersStr = request.getParameter("passengers");

        // VALIDATION for (all fields required, passengers must be a number between 1
        // and 100, date cannot be in the past)
        if (destination == null || date == null || passengersStr == null ||
                destination.isEmpty() || date.isEmpty() || passengersStr.isEmpty()) {

            response.getWriter().println("All fields are required");
            return;
        }

        try {
            int passengers = Integer.parseInt(passengersStr);

            if (passengers <= 0 || passengers > 100) {
                response.getWriter().println("Passengers must be between 1 and 100");
                return;
            }

            // Date validation
            java.time.LocalDate selectedDate = java.time.LocalDate.parse(date);
            java.time.LocalDate today = java.time.LocalDate.now();

            if (selectedDate.isBefore(today)) {
                response.getWriter().println("Date cannot be in the past");
                return;
            }

            // Create Trip object (Murach model usage)
            String id = "TP-" + (int) (Math.random() * 1000);
            Trip trip = new Trip(id, destination, date, passengers);

            HttpSession session = request.getSession();

            List<Trip> trips = getSessionAttribute(session, "trips");

            if (trips == null) {
                trips = new ArrayList<>();
            }

            trips.add(trip);

            session.setAttribute("trips", trips);

        } catch (NumberFormatException e) {
            response.getWriter().println("Passengers must be a valid number");
            return;
        }

        // PRG to prevent creation of a jsp and also prevent form resubmission on
        // refresh
        response.sendRedirect("DriverDashboardServlet");
    }
}