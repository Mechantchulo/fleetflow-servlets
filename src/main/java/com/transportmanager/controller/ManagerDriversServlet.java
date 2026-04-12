package com.transportmanager.controller;

import com.transportmanager.dao.DriverDAO;
import com.transportmanager.model.Driver;
import com.transportmanager.util.ManagerSessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.Locale;

@WebServlet(name = "ManagerDriversServlet", urlPatterns = {"/manager/drivers"})
public class ManagerDriversServlet extends HttpServlet {

    private transient DriverDAO driverDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        this.driverDAO = new DriverDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        if (!ManagerSessionUtil.isManagerLoggedIn(request)) {
            ManagerSessionUtil.redirectToLogin(request, response);
            return;
        }

        List<Driver> drivers = driverDAO.findAllDrivers();
        request.setAttribute("drivers", drivers);
        request.getRequestDispatcher("/WEB-INF/manager/manageDrivers.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (!ManagerSessionUtil.isManagerLoggedIn(request)) {
            ManagerSessionUtil.redirectToLogin(request, response);
            return;
        }

        String fullName = trim(request.getParameter("fullName"));
        String email = trim(request.getParameter("email")).toLowerCase(Locale.ROOT);
        String username = trim(request.getParameter("username")).toLowerCase(Locale.ROOT);
        String licenseNumber = trim(request.getParameter("licenseNumber"));
        String password = trim(request.getParameter("password"));

        if (fullName.isEmpty() || email.isEmpty() || username.isEmpty() || licenseNumber.isEmpty() || password.length() < 8) {
            response.sendRedirect(request.getContextPath() + "/manager/drivers?error=invalidDriverInput");
            return;
        }

        boolean created = driverDAO.createApprovedDriver(fullName, email, username, licenseNumber, password);
        if (!created) {
            response.sendRedirect(request.getContextPath() + "/manager/drivers?error=driverCreateFailed");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/manager/drivers?success=driverCreated");
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
