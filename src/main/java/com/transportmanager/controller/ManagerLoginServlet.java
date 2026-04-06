package com.transportmanager.controller;

import com.transportmanager.util.ManagerSessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "ManagerLoginServlet", urlPatterns = {"/manager/login"})
public class ManagerLoginServlet extends HttpServlet {

	private static final String LOGIN_JSP = "/WEB-INF/manager/managerLogin.jsp";
	private static final String MANAGER_ROLE = "TRANSPORT_MANAGER";

	// Temporary credentials for learning/demo purposes.
	// Replace with DAO/service validation against a real users table.
	private static final String DEMO_USERNAME = "manager";
	private static final String DEMO_PASSWORD = "manager123";

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
		if (ManagerSessionUtil.isManagerLoggedIn(request)) {
			response.sendRedirect(request.getContextPath() + "/manager/trips/pending");
			return;
		}

		request.getRequestDispatcher(LOGIN_JSP).forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
		String username = trimToEmpty(request.getParameter("username"));
		String password = trimToEmpty(request.getParameter("password"));

		if (username.isEmpty() || password.isEmpty()) {
			request.setAttribute("error", "Username and password are required.");
			request.getRequestDispatcher(LOGIN_JSP).forward(request, response);
			return;
		}

		if (!isValidManagerCredentials(username, password)) {
			request.setAttribute("error", "Invalid credentials. Try again.");
			request.setAttribute("username", username);
			request.getRequestDispatcher(LOGIN_JSP).forward(request, response);
			return;
		}

		HttpSession session = request.getSession(true);
		session.setAttribute("userRole", MANAGER_ROLE);
		session.setAttribute("managerUsername", username);
		session.setMaxInactiveInterval(30 * 60);

		response.sendRedirect(request.getContextPath() + "/manager/trips/pending");
	}

	private boolean isValidManagerCredentials(String username, String password) {
		return DEMO_USERNAME.equals(username) && DEMO_PASSWORD.equals(password);
	}

	private String trimToEmpty(String value) {
		return value == null ? "" : value.trim();
	}
}

