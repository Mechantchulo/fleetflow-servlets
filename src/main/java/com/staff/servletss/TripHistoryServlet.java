package com.staff.servletss;

import com.staff.dao.StaffTripDAO;
import com.staff.model.Trip;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet(urlPatterns = {"/staff/TripHistory", "/staff/trip-history"})
public class TripHistoryServlet extends HttpServlet {

    private transient StaffTripDAO staffTripDAO;

    @Override
    public void init() {
        this.staffTripDAO = new StaffTripDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !"STAFF".equals(session.getAttribute("userRole"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        String staffUsername = String.valueOf(session.getAttribute("username"));
        String tab = request.getParameter("tab");      // all, completed, cancelled
        String search = request.getParameter("search"); // search query

        List<Trip> trips = staffTripDAO.findTripHistoryByStaff(staffUsername);
        List<Trip> filteredTrips = trips;

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

        request.getRequestDispatcher("/WEB-INF/staff/TripHistory.jsp")
               .forward(request, response);
    }
}
