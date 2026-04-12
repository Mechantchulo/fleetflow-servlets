package com.auth;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Locale;

@WebServlet(name = "StaffSignupServlet", urlPatterns = {"/signup/staff"})
public class StaffSignupServlet extends HttpServlet {

    private transient AuthDAO authDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        this.authDAO = new AuthDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/auth/staffSignup.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String fullName = trim(request.getParameter("fullName"));
        String department = trim(request.getParameter("department"));
        String email = trim(request.getParameter("email")).toLowerCase(Locale.ROOT);
        String username = trim(request.getParameter("username")).toLowerCase(Locale.ROOT);
        String password = trim(request.getParameter("password"));
        String confirmPassword = trim(request.getParameter("confirmPassword"));

        if (fullName.isEmpty() || department.isEmpty() || email.isEmpty() || username.isEmpty() || password.isEmpty()) {
            request.setAttribute("error", "All fields are required.");
            preserveInputs(request, fullName, department, email, username);
            request.getRequestDispatcher("/WEB-INF/auth/staffSignup.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match.");
            preserveInputs(request, fullName, department, email, username);
            request.getRequestDispatcher("/WEB-INF/auth/staffSignup.jsp").forward(request, response);
            return;
        }

        if (password.length() < 8) {
            request.setAttribute("error", "Password must be at least 8 characters.");
            preserveInputs(request, fullName, department, email, username);
            request.getRequestDispatcher("/WEB-INF/auth/staffSignup.jsp").forward(request, response);
            return;
        }

        boolean created = authDAO.registerStaff(fullName, department, email, username, password);
        if (!created) {
            request.setAttribute("error", "Could not create account. Username or email may already exist.");
            preserveInputs(request, fullName, department, email, username);
            request.getRequestDispatcher("/WEB-INF/auth/staffSignup.jsp").forward(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/login?signup=staffSuccess");
    }

    private void preserveInputs(HttpServletRequest request,
                                String fullName,
                                String department,
                                String email,
                                String username) {
        request.setAttribute("fullName", fullName);
        request.setAttribute("department", department);
        request.setAttribute("email", email);
        request.setAttribute("username", username);
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
