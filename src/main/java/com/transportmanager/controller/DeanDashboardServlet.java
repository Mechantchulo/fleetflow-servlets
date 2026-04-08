package com.transportmanager.controller;

import com.transportmanager.dao.TripDAO;
import com.transportmanager.model.Trip;
import com.transportmanager.util.DbUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "DeanDashboardServlet", urlPatterns = {"/dean/dashboard"})
public class DeanDashboardServlet extends HttpServlet {

    private static final String DEAN_DASHBOARD_JSP = "/WEB-INF/dean/deanDashboard.jsp";

    private transient TripDAO tripDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        this.tripDAO = new TripDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        // 1. CENTRALIZED SECURITY CHECK
        // We explicitly check the session here and bounce unauthorized users to the shared front door.
        HttpSession session = request.getSession(false);
        if (session == null || !"DEAN".equals(session.getAttribute("userRole"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            // Fetch dashboard statistics
            Map<String, Object> dashboardStats = getDashboardStatistics();
            request.setAttribute("dashboardStats", dashboardStats);

            // Fetch recent trips for overview
            List<Trip> recentTrips = tripDAO.findPendingTripsSorted(1, 10, null, null, null);
            request.setAttribute("recentTrips", recentTrips);

            // Fetch fleet utilization data
            Map<String, Object> fleetUtilization = getFleetUtilization();
            request.setAttribute("fleetUtilization", fleetUtilization);

        } catch (Exception ex) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Failed to load dashboard data.");
            return;
        }

        request.getRequestDispatcher(DEAN_DASHBOARD_JSP).forward(request, response);
    }

    // --- We removed the doPost() and authentication methods from here ---

    private Map<String, Object> getDashboardStatistics() {
        Map<String, Object> stats = new HashMap<>();
        
        String sql = """
            SELECT 
                COUNT(CASE WHEN tr.status = 'PENDING' THEN 1 END) as pending_trips,
                COUNT(CASE WHEN tr.status = 'APPROVED' THEN 1 END) as approved_trips,
                COUNT(CASE WHEN tr.status = 'REJECTED' THEN 1 END) as rejected_trips,
                COUNT(CASE WHEN tr.status = 'ASSIGNED' THEN 1 END) as assigned_trips,
                COUNT(CASE WHEN DATE(tr.departure_time) = CURRENT_DATE THEN 1 END) as today_trips,
                COALESCE(SUM(CASE WHEN tr.status = 'PENDING' THEN tr.passenger_count ELSE 0 END), 0) as pending_passengers
            FROM trip_request tr
            WHERE tr.departure_time >= CURRENT_DATE - INTERVAL '30 days'
        """;

        try (Connection connection = DbUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet rs = statement.executeQuery()) {
            
            if (rs.next()) {
                stats.put("pendingTrips", rs.getInt("pending_trips"));
                stats.put("approvedTrips", rs.getInt("approved_trips"));
                stats.put("rejectedTrips", rs.getInt("rejected_trips"));
                stats.put("assignedTrips", rs.getInt("assigned_trips"));
                stats.put("todayTrips", rs.getInt("today_trips"));
                stats.put("pendingPassengers", rs.getInt("pending_passengers"));
            }
        } catch (SQLException ex) {
            stats.put("pendingTrips", 0);
            stats.put("approvedTrips", 0);
            stats.put("rejectedTrips", 0);
            stats.put("assignedTrips", 0);
            stats.put("todayTrips", 0);
            stats.put("pendingPassengers", 0);
        }

        return stats;
    }

    private Map<String, Object> getFleetUtilization() {
        Map<String, Object> utilization = new HashMap<>();
        
        String sql = """
            SELECT 
                COUNT(v.id) as total_vehicles,
                COUNT(CASE WHEN v.status = 'AVAILABLE' THEN 1 END) as available_vehicles,
                COUNT(CASE WHEN v.status = 'ASSIGNED' THEN 1 END) as assigned_vehicles,
                COUNT(CASE WHEN v.status = 'MAINTENANCE' THEN 1 END) as maintenance_vehicles,
                COUNT(d.id) as total_drivers,
                COUNT(CASE WHEN d.status = 'AVAILABLE' THEN 1 END) as available_drivers,
                COUNT(CASE WHEN d.status = 'ASSIGNED' THEN 1 END) as assigned_drivers
            FROM vehicle v
            LEFT JOIN users d ON d.role = 'DRIVER'
        """;

        try (Connection connection = DbUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet rs = statement.executeQuery()) {
            
            if (rs.next()) {
                utilization.put("totalVehicles", rs.getInt("total_vehicles"));
                utilization.put("availableVehicles", rs.getInt("available_vehicles"));
                utilization.put("assignedVehicles", rs.getInt("assigned_vehicles"));
                utilization.put("maintenanceVehicles", rs.getInt("maintenance_vehicles"));
                utilization.put("totalDrivers", rs.getInt("total_drivers"));
                utilization.put("availableDrivers", rs.getInt("available_drivers"));
                utilization.put("assignedDrivers", rs.getInt("assigned_drivers"));
            }
        } catch (SQLException ex) {
            utilization.put("totalVehicles", 0);
            utilization.put("availableVehicles", 0);
            utilization.put("assignedVehicles", 0);
            utilization.put("maintenanceVehicles", 0);
            utilization.put("totalDrivers", 0);
            utilization.put("availableDrivers", 0);
            utilization.put("assignedDrivers", 0);
        }

        return utilization;
    }
}