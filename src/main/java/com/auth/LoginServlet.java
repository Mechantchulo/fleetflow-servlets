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

    private transient AuthDAO authDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        this.authDAO = new AuthDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if ("1".equals(request.getParameter("loggedOut"))) {
            request.setAttribute("logoutMessage", "You have been logged out.");
        }
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = trimToEmpty(request.getParameter("username")).toLowerCase();
        String password = trimToEmpty(request.getParameter("password"));

        if (username.isEmpty() || password.isEmpty()) {
            request.setAttribute("error", "Username and password are required.");
            request.getRequestDispatcher("/index.jsp").forward(request, response);
            return;
        }

        AuthUser user = authDAO.authenticate(username, password);
        if (user == null) {
            request.setAttribute("error", "Invalid credentials. Try again.");
            request.setAttribute("username", username);
            request.getRequestDispatcher("/index.jsp").forward(request, response);
            return;
        }

        authDAO.markSuccessfulLogin(user.getId());

        HttpSession session = request.getSession(true);
        session.setMaxInactiveInterval(30 * 60);
        session.setAttribute("username", user.getUsername());
        session.setAttribute("fullName", user.getFullName());
        session.setAttribute("userRole", user.getRole());
        if ("TRANSPORT_MANAGER".equalsIgnoreCase(user.getRole())) {
            session.setAttribute("managerUsername", user.getUsername());
        }

        String role = user.getRole() == null ? "" : user.getRole().toUpperCase();
        if ("DEAN".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/dean/dashboard");
            return;
        }
        if ("TRANSPORT_MANAGER".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/manager/dashboard");
            return;
        }
        if ("STAFF".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/staff/dashboard");
            return;
        }
        if ("DRIVER".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/driver/dashboard");
            return;
        }
        if ("TIMETABLING_STAFF".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/timetabling/dashboard");
            return;
        }

        session.invalidate();
        request.setAttribute("error", "Your account role is not configured for this system.");
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }

    private String trimToEmpty(String value) {
        return value == null ? "" : value.trim();
    }
}
