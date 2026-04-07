package com.staff.servletss;

import com.staff.model.Trip;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/staff/TripHistory")
public class TripHistoryServlet extends HttpServlet {

    // Simulated database
    private static List<Trip> trips = new ArrayList<>();

    @Override
    public void init() {
        // Sample data (runs once when server starts)
        if (!trips.isEmpty()) {
            return;
        }

        trips.add(new Trip(1, "2026-04-01", "John Doe", "JD", "Nairobi - Nakuru", "3h", "Completed"));
        trips.add(new Trip(2, "2026-04-02", "Jane Smith", "JS", "Nairobi - Mombasa", "8h", "Cancelled"));
        trips.add(new Trip(3, "2026-04-03", "Mike Lee", "ML", "Nairobi - Kisumu", "6h", "Completed"));
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String tab = request.getParameter("tab");      // all, completed, cancelled
        String search = request.getParameter("search"); // search query

        List<Trip> filteredTrips = new ArrayList<>(trips);

        // 🔍 Filter by tab
        if (tab != null && !tab.equals("all")) {
            filteredTrips = filteredTrips.stream()
                    .filter(t -> t.getStatus().equalsIgnoreCase(tab))
                    .collect(Collectors.toList());
        }

        // 🔎 Search filter
        if (search != null && !search.trim().isEmpty()) {
            String query = search.toLowerCase();

            filteredTrips = filteredTrips.stream()
                    .filter(t ->
                            String.valueOf(t.getId()).contains(query) ||
                            t.getDriver().toLowerCase().contains(query) ||
                            t.getRoute().toLowerCase().contains(query)
                    )
                    .collect(Collectors.toList());
        }

        // Counts (for tabs)
        long completedCount = trips.stream()
                .filter(t -> t.getStatus().equalsIgnoreCase("Completed")).count();

        long cancelledCount = trips.stream()
                .filter(t -> t.getStatus().equalsIgnoreCase("Cancelled")).count();

        // Send data to JSP
        request.setAttribute("trips", filteredTrips);
        request.setAttribute("activeTab", tab == null ? "all" : tab);
        request.setAttribute("search", search == null ? "" : search);
        request.setAttribute("completedCount", completedCount);
        request.setAttribute("cancelledCount", cancelledCount);

        request.getRequestDispatcher("/staff/TripHistory.jsp")
               .forward(request, response);
    }
}
