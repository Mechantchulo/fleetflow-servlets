package com.transportmanager.controller;

import com.transportmanager.dao.BusDAO;
import com.transportmanager.util.ManagerSessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "AllocateBusServlet", urlPatterns = {"/manager/allocation/bus/assign"})
public class AllocateBusServlet extends HttpServlet {
	private static final String STAGED_BUS_PREFIX = "stagedBusForTrip_";
	private static final String STAGED_OVERRIDE_PREFIX = "stagedOverrideForTrip_";
	private static final String STAGED_OVERRIDE_REASON_PREFIX = "stagedOverrideReasonForTrip_";

	private transient BusDAO busDAO;

	@Override
	public void init() throws ServletException {
		super.init();
		this.busDAO = new BusDAO();
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
		if (!ManagerSessionUtil.isManagerLoggedIn(request)) {
			ManagerSessionUtil.redirectToLogin(request, response);
			return;
		}

		long tripId = parseLongOrDefault(request.getParameter("tripId"), -1L);
		long busId = parseLongOrDefault(request.getParameter("busId"), -1L);
		boolean override = Boolean.parseBoolean(trimToEmpty(request.getParameter("override")));
		String overrideReason = trimToNull(request.getParameter("overrideReason"));

		if (tripId <= 0 || busId <= 0) {
			response.sendRedirect(request.getContextPath() + "/manager/allocation/buses?tripId=" + tripId + "&error=invalidAssignInput");
			return;
		}

		if (override && overrideReason == null) {
			response.sendRedirect(request.getContextPath() + "/manager/allocation/buses?tripId=" + tripId + "&error=overrideReasonRequired");
			return;
		}

		boolean busAvailable;
		try {
			busAvailable = busDAO.isBusAvailable(busId);
		} catch (Exception ex) {
			response.sendRedirect(request.getContextPath() + "/manager/allocation/buses?tripId=" + tripId + "&error=busAvailabilityCheckFailed");
			return;
		}

		if (!busAvailable && !override) {
			response.sendRedirect(request.getContextPath() + "/manager/allocation/buses?tripId=" + tripId + "&error=busUnavailable");
			return;
		}

		HttpSession session = request.getSession(true);
		session.setAttribute(STAGED_BUS_PREFIX + tripId, busId);
		session.setAttribute(STAGED_OVERRIDE_PREFIX + tripId, override);
		session.setAttribute(STAGED_OVERRIDE_REASON_PREFIX + tripId, overrideReason);

		response.sendRedirect(request.getContextPath() + "/manager/allocation/drivers?tripId=" + tripId + "&success=busSelected");
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
		response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED, "Use POST to assign a bus to a trip.");
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

	private String trimToNull(String raw) {
		if (raw == null) {
			return null;
		}
		String value = raw.trim();
		return value.isEmpty() ? null : value;
	}

	private String trimToEmpty(String raw) {
		return raw == null ? "" : raw.trim();
	}
}

