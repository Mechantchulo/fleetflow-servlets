package com.auth;

// import com.transportmanager.util.DeanSessionUtil;
// import com.transportmanager.util.ManagerSessionUtil;
// import com.staff.servletss.StaffDashboardServlet;
// import com.driver.driverdashboard.DriverDashboardServlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    // Demo credentials
    private static final String DEAN_USER = "dean";
    private static final String DEAN_PASS = "dean123";

    private static final String MANAGER_USER = "manager";
    private static final String MANAGER_PASS = "manager123";

    private static final String STAFF_USER = "staff";
    private static final String STAFF_PASS = "staff123";

    private static final String DRIVER_USER = "driver";
    private static final String DRIVER_PASS = "driver123";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Show login page
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = trimToEmpty(request.getParameter("username"));
        String password = trimToEmpty(request.getParameter("password"));

        if (username.isEmpty() || password.isEmpty()) {
            request.setAttribute("error", "Username and password are required.");
            request.getRequestDispatcher("/index.jsp").forward(request, response);
            return;
        }

        HttpSession session = request.getSession(true);

        // Role-based authentication
        if (DEAN_USER.equals(username) && DEAN_PASS.equals(password)) {
            session.setAttribute("userRole", "DEAN");
            session.setAttribute("username", username);
            session.setMaxInactiveInterval(30 * 60);
            response.sendRedirect(request.getContextPath() + "/dean/dashboard");
            return;
        }

        if (MANAGER_USER.equals(username) && MANAGER_PASS.equals(password)) {
            session.setAttribute("userRole", "TRANSPORT_MANAGER");
            session.setAttribute("username", username);
            session.setMaxInactiveInterval(30 * 60);
            response.sendRedirect(request.getContextPath() + "/manager/trips/pending");
            return;
        }

        if (STAFF_USER.equals(username) && STAFF_PASS.equals(password)) {
            session.setAttribute("userRole", "STAFF");
            session.setAttribute("username", username);
            session.setMaxInactiveInterval(30 * 60);
            response.sendRedirect(request.getContextPath() + "/dashboard"); // StaffDashboardServlet
            return;
        }

        if (DRIVER_USER.equals(username) && DRIVER_PASS.equals(password)) {
            session.setAttribute("userRole", "DRIVER");
            session.setAttribute("username", username);
            session.setMaxInactiveInterval(30 * 60);
            response.sendRedirect(request.getContextPath() + "/driver/dashboard"); // DriverDashboardServlet
            return;
        }

        // Invalid credentials
        request.setAttribute("error", "Invalid credentials. Try again.");
        request.setAttribute("username", username);
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }

    private String trimToEmpty(String value) {
        return value == null ? "" : value.trim();
    }
}