package com.driver.TripLogs;

import java.io.*;
import java.util.*;
// import jakarta.servlet.*;
import jakarta.servlet.http.*;

public class TripLogServlet extends HttpServlet {

    @SuppressWarnings("unchecked")
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession();

        ArrayList<TripLog> tripLogs = (ArrayList<TripLog>) session.getAttribute("tripLogs");
        if (tripLogs == null) {
            tripLogs = new ArrayList<>();
            session.setAttribute("tripLogs", tripLogs);
        }

        out.println("<h2>Trip Logs</h2>");
        out.println("<a href='DriverDashboardServlet'>Back to Dashboard</a><br><br>");

        // Form to add trip log
        out.println("<h3>Add Trip Log</h3>");
        out.println("<form method='post'>");
        out.println("Start Mileage: <input type='number' min='0' name='startMileage' required><br>");
        out.println("End Mileage: <input type='number' min='0' name='endMileage' required><br>");
        out.println("Fuel Used (Litres): <input type='number' min='0' step='0.1' name='fuelUsed' required><br>");
        out.println("Trip Time: <input type='datetime-local' name='timestamp' required><br>");
        out.println("Comments: <input type='text' name='comments'><br>");
        out.println("<button type='submit'>Add Trip Log</button>");
        out.println("</form>");

        // Display table
        out.println("<h3>All Trip Logs</h3>");
        out.println("<table border='1'>");
        out.println(
                "<tr><th>Start Mileage</th><th>End Mileage</th><th>Distance</th><th>Fuel Used</th><th>Timestamp</th><th>Comments</th></tr>");

        for (TripLog log : tripLogs) {
            out.println("<tr>");
            out.println("<td>" + log.getStartMileage() + "</td>");
            out.println("<td>" + log.getEndMileage() + "</td>");
            out.println("<td>" + log.getDistance() + "</td>");
            out.println("<td>" + log.getFuelUsed() + "</td>");
            out.println("<td>" + log.getTimestamp() + "</td>");
            out.println("<td>" + log.getComments() + "</td>");
            out.println("</tr>");
        }
        out.println("</table>");
    }

    @SuppressWarnings("unchecked")
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String startStr = request.getParameter("startMileage");
        String endStr = request.getParameter("endMileage");
        String fuelStr = request.getParameter("fuelUsed");
        String timestamp = request.getParameter("timestamp");
        String comments = request.getParameter("comments");

        if (startStr.isEmpty() || endStr.isEmpty() || fuelStr.isEmpty() || timestamp.isEmpty()) {
            response.getWriter().println("All fields except comments are required");
            return;
        }

        try {
            int startMileage = Integer.parseInt(startStr);
            int endMileage = Integer.parseInt(endStr);
            double fuelUsed = Double.parseDouble(fuelStr);
            if (startMileage < 0 || endMileage < 0 || fuelUsed < 0) {
                response.getWriter().println("Start mileage, end mileage, and fuel used cannot be negative");
                return;
            }

            if (endMileage < startMileage) {
                response.getWriter().println("End Mileage cannot be less than Start Mileage");
                return;
            }

            TripLog log = new TripLog(startMileage, endMileage, fuelUsed, timestamp, comments);

            HttpSession session = request.getSession();
            ArrayList<TripLog> tripLogs = (ArrayList<TripLog>) session.getAttribute("tripLogs");
            if (tripLogs == null)
                tripLogs = new ArrayList<>();

            tripLogs.add(log);
            session.setAttribute("tripLogs", tripLogs);

        } catch (NumberFormatException e) {
            response.getWriter().println("Start Mileage, End Mileage, and Fuel Used must be numbers");
            return;
        }

        // PRG Pattern prevent resubmission
        response.sendRedirect("TripLogsServlet");
    }
}
