package com.transportmanager.util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

public final class ManagerSessionUtil {

	private ManagerSessionUtil() {
	}

	public static boolean isManagerLoggedIn(HttpServletRequest request) {
		HttpSession session = request.getSession(false);
		if (session == null) {
			return false;
		}

		Object role = session.getAttribute("userRole");
		if (role == null) {
			return false;
		}

		return "TRANSPORT_MANAGER".equalsIgnoreCase(String.valueOf(role));
	}

	public static void redirectToLogin(HttpServletRequest request, HttpServletResponse response) throws IOException {
		String contextPath = request.getContextPath();
		response.sendRedirect(contextPath + "/login");
	}
}
