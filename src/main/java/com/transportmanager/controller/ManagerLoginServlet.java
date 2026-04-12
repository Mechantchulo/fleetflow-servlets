package com.transportmanager.controller;

import com.auth.AuthDAO;
import com.auth.AuthUser;
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

	private static final String MANAGER_ROLE = "TRANSPORT_MANAGER";
	private transient AuthDAO authDAO;

	@Override
	public void init() throws ServletException {
		super.init();
		this.authDAO = new AuthDAO();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
		if (ManagerSessionUtil.isManagerLoggedIn(request)) {
			response.sendRedirect(request.getContextPath() + "/manager/trips/pending");
			return;
		}
		response.sendRedirect(request.getContextPath() + "/login");
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
		String username = trimToEmpty(request.getParameter("username"));
		String password = trimToEmpty(request.getParameter("password"));

		if (username.isEmpty() || password.isEmpty()) {
			response.sendRedirect(request.getContextPath() + "/login");
			return;
		}

		AuthUser user = authDAO.authenticate(username.toLowerCase(), password);
		if (user == null || !MANAGER_ROLE.equalsIgnoreCase(user.getRole())) {
			response.sendRedirect(request.getContextPath() + "/login");
			return;
		}
		authDAO.markSuccessfulLogin(user.getId());

		HttpSession session = request.getSession(true);
		session.setAttribute("userRole", MANAGER_ROLE);
		session.setAttribute("username", user.getUsername());
		session.setAttribute("fullName", user.getFullName());
		session.setAttribute("managerUsername", user.getUsername());
		session.setMaxInactiveInterval(30 * 60);

		response.sendRedirect(request.getContextPath() + "/manager/trips/pending");
	}

	private String trimToEmpty(String value) {
		return value == null ? "" : value.trim();
	}
}
