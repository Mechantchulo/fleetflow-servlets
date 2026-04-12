package com.transportmanager.controller;

import com.transportmanager.dao.TripDAO;
import com.transportmanager.util.ManagerSessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "TripDecisionServlet", urlPatterns = {"/manager/trips/decision"})
public class TripDecisionServlet extends HttpServlet {

	private transient TripDAO tripDAO;

	@Override
	public void init() throws ServletException {
		super.init();
		this.tripDAO = new TripDAO();
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
		if (!ManagerSessionUtil.isManagerLoggedIn(request)) {
			ManagerSessionUtil.redirectToLogin(request, response);
			return;
		}

		long tripId = parseLongOrDefault(request.getParameter("tripId"), -1L);
		String action = normalizeAction(request.getParameter("action"));
		String managerNote = trimToNull(request.getParameter("managerNote"));

		if (tripId <= 0 || action == null) {
			response.sendRedirect(request.getContextPath() + "/manager/trips/pending?error=invalidDecisionInput");
			return;
		}

		HttpSession session = request.getSession(false);
		String managerUsername = session == null ? "unknown" : String.valueOf(session.getAttribute("managerUsername"));

		boolean updated;
		try {
			updated = tripDAO.updateTripDecision(tripId, action, managerNote, managerUsername);
		} catch (Exception ex) {
			response.sendRedirect(request.getContextPath() + "/manager/trips/pending?error=decisionFailed");
			return;
		}

		if (!updated) {
			response.sendRedirect(request.getContextPath() + "/manager/trips/pending?error=tripNotUpdated");
			return;
		}

		response.sendRedirect(request.getContextPath() + "/manager/trips/pending?success=decisionSaved:" + action.toLowerCase());
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
		response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED, "Use POST to approve or reject a trip request.");
	}

	private long parseLongOrDefault(String raw, long defaultValue) {
		if (raw == null || raw.isBlank()) {
			return defaultValue;
		}

		try {
			return Long.parseLong(raw.trim());
		} catch (NumberFormatException ex) {
			return defaultValue;
		}
	}

	private String normalizeAction(String raw) {
		if (raw == null || raw.isBlank()) {
			return null;
		}

		String value = raw.trim().toUpperCase();
		if ("APPROVE".equals(value) || "REJECT".equals(value) || "CONFIRM".equals(value)) {
			return value;
		}
		return null;
	}

	private String trimToNull(String raw) {
		if (raw == null) {
			return null;
		}

		String value = raw.trim();
		return value.isEmpty() ? null : value;
	}
}
