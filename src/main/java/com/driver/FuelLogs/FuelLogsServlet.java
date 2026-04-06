package com.driver.FuelLogs;

import java.io.*;
import java.util.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;

public class FuelLogsServlet extends HttpServlet {

    @SuppressWarnings("unchecked")
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession();

        ArrayList<FuelLogs> logs = (ArrayList<FuelLogs>) session.getAttribute("logs");
        if (logs == null) {
            logs = new ArrayList<>();
            session.setAttribute("logs", logs);
        }

        out.println("<h2>Fuel Logs</h2>");
        out.println("<a href='DriverDashboardServlet'>Back to Dashboard</a><br><br>");

        // Form to add fuel logs
        out.println("<h3>Add Fuel Log</h3>");
        out.println("<form method='post'>");
        out.println("Date: <input type='date' name='date'><br>");
        out.println("Start Mileage: <input type='number' name='startMileage'><br>");
        out.println("End Mileage: <input type='number' name='endMileage'><br>");
        out.println("Fuel Used (Litres): <input type='number' step='0.1' name='fuelUsed'><br>");
        out.println("Comments: <input type='text' name='comments'><br>");
        out.println("<button type='submit'>Add Log</button>");
        out.println("</form>");

        // Display table
        out.println("<h3>All Fuel Logs</h3>");
        out.println("<table border='1'>");
        out.println(
                "<tr><th>Date</th><th>Start</th><th>End</th><th>Distance</th><th>Fuel Used</th><th>Comments</th></tr>");

        for (FuelLogs log : logs) {
            out.println("<tr>");
            out.println("<td>" + log.getDate() + "</td>");
            out.println("<td>" + log.getStartMileage() + "</td>");
            out.println("<td>" + log.getEndMileage() + "</td>");
            out.println("<td>" + log.getDistance() + "</td>");
            out.println("<td>" + log.getFuelUsed() + "</td>");
            out.println("<td>" + log.getComments() + "</td>");
            out.println("</tr>");
        }
        out.println("</table>");
    }

    @SuppressWarnings("unchecked")
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String date = request.getParameter("date");
        String startStr = request.getParameter("startMileage");
        String endStr = request.getParameter("endMileage");
        String fuelStr = request.getParameter("fuelUsed");
        String comments = request.getParameter("comments");

        // Simple validation
        if (date.isEmpty() || startStr.isEmpty() || endStr.isEmpty() || fuelStr.isEmpty()) {
            response.getWriter().println("All fields except comments are required");
            return;
        }

        try {
            int startMileage = Integer.parseInt(startStr);
            int endMileage = Integer.parseInt(endStr);
            double fuelUsed = Double.parseDouble(fuelStr);

            if (endMileage < startMileage) {
                response.getWriter().println("End mileage cannot be less than start mileage");
                return;
            }

            FuelLogs log = new FuelLogs(date, startMileage, endMileage, fuelUsed, comments);

            HttpSession session = request.getSession();
            ArrayList<FuelLogs> logs = (ArrayList<FuelLogs>) session.getAttribute("logs");
            if (logs == null)
                logs = new ArrayList<>();

            logs.add(log);
            session.setAttribute("logs", logs);

        } catch (NumberFormatException e) {
            response.getWriter().println("Mileage and fuel used must be numbers");
            return;
        }

        response.sendRedirect("FuelLogsServlet"); // PRG pattern
    }
}
