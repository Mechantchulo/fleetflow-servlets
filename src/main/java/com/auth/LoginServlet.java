package com.auth;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
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

        // Create a new session for the user
        HttpSession session = request.getSession(true);
        session.setMaxInactiveInterval(30 * 60); // 30 minutes timeout
        session.setAttribute("username", username);

        // --- ROLE-BASED ROUTING ---
        // We are using clean, standardized URLs for every role's dashboard.

        if ("dean".equals(username) && "dean123".equals(password)) {
            session.setAttribute("userRole", "DEAN");
            response.sendRedirect(request.getContextPath() + "/dean/dashboard");
            return;
        }

        if ("manager".equals(username) && "manager123".equals(password)) {
            session.setAttribute("userRole", "TRANSPORT_MANAGER");
            response.sendRedirect(request.getContextPath() + "/manager/dashboard");
            return;
        }

        if ("staff".equals(username) && "staff123".equals(password)) {
            session.setAttribute("userRole", "STAFF");
            response.sendRedirect(request.getContextPath() + "/staff/dashboard");
            return;
        }

        if ("driver".equals(username) && "driver123".equals(password)) {
            session.setAttribute("userRole", "DRIVER");
            response.sendRedirect(request.getContextPath() + "/driver/dashboard");
            return;
        }

        // If we get here, credentials failed
        session.invalidate(); // Destroy the session we just made
        request.setAttribute("error", "Invalid credentials. Try again.");
        request.setAttribute("username", username); // Keep username in the box so they don't have to retype it
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }

    private String trimToEmpty(String value) {
        return value == null ? "" : value.trim();
    }
}