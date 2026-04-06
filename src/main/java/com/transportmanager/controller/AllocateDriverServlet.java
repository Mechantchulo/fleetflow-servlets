package com.transportmanager.controller;

import com.transportmanager.dao.DriverDAO;
import com.transportmanager.dao.TripDAO;
import com.transportmanager.util.ManagerSessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "AllocateDriverServlet", urlPatterns = {"/manager/allocation/driver/assign"})
public class AllocateDriverServlet extends HttpServlet {
	private static final String STAGED_BUS_PREFIX = "stagedBusForTrip_";
	private static final String STAGED_OVERRIDE_PREFIX = "stagedOverrideForTrip_";
	private static final String STAGED_OVERRIDE_REASON_PREFIX = "stagedOverrideReasonForTrip_";

	private transient TripDAO tripDAO;
	private transient DriverDAO driverDAO;

	@Override
	public void init() throws ServletException {
		super.init();
		this.tripDAO = new TripDAO();
		this.driverDAO = new DriverDAO();
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
		if (!ManagerSessionUtil.isManagerLoggedIn(request)) {
			ManagerSessionUtil.redirectToLogin(request, response);
			return;
		}

		long tripId = parseLongOrDefault(request.getParameter("tripId"), -1L);
		long driverId = parseLongOrDefault(request.getParameter("driverId"), -1L);
		HttpSession session = request.getSession(false);
		long stagedBusId = readStagedBusId(session, tripId);
		boolean override = readStagedOverride(session, tripId) || Boolean.parseBoolean(trimToEmpty(request.getParameter("override")));
		String overrideReason = readStagedOverrideReason(session, tripId);
		if (overrideReason == null) {
			overrideReason = trimToNull(request.getParameter("overrideReason"));
		}

		if (tripId <= 0 || driverId <= 0 || stagedBusId <= 0) {
			response.sendRedirect(request.getContextPath() + "/manager/allocation/drivers?tripId=" + tripId + "&error=invalidAssignInput");
			return;
		}

		if (override && overrideReason == null) {
			response.sendRedirect(request.getContextPath() + "/manager/allocation/drivers?tripId=" + tripId + "&error=overrideReasonRequired");
			return;
		}

		boolean driverAvailable;
		try {
			driverAvailable = driverDAO.isDriverAvailable(driverId);
		} catch (Exception ex) {
			response.sendRedirect(request.getContextPath() + "/manager/allocation/drivers?tripId=" + tripId + "&error=driverAvailabilityCheckFailed");
			return;
		}

		if (!driverAvailable && !override) {
			response.sendRedirect(request.getContextPath() + "/manager/allocation/drivers?tripId=" + tripId + "&error=driverUnavailable");
			return;
		}

		String managerUsername = session == null ? "unknown" : String.valueOf(session.getAttribute("managerUsername"));

		boolean assigned;
		try {
			assigned = tripDAO.assignBusAndDriverToTrip(tripId, stagedBusId, driverId, override, overrideReason, managerUsername);
		} catch (Exception ex) {
			response.sendRedirect(request.getContextPath() + "/manager/allocation/drivers?tripId=" + tripId + "&error=assignFailed");
			return;
		}

		if (!assigned) {
			response.sendRedirect(request.getContextPath() + "/manager/allocation/drivers?tripId=" + tripId + "&error=assignNotSaved");
			return;
		}

		clearStagedSelection(session, tripId);
		response.sendRedirect(request.getContextPath() + "/manager/trips/pending?success=driverAssigned");
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
		response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED, "Use POST to assign a driver to a trip.");
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

	private long readStagedBusId(HttpSession session, long tripId) {
		if (session == null) {
			return -1L;
		}
		Object value = session.getAttribute(STAGED_BUS_PREFIX + tripId);
		if (value instanceof Long) {
			return (Long) value;
		}
		if (value instanceof Integer) {
			return ((Integer) value).longValue();
		}
		return -1L;
	}

	private boolean readStagedOverride(HttpSession session, long tripId) {
		if (session == null) {
			return false;
		}
		Object value = session.getAttribute(STAGED_OVERRIDE_PREFIX + tripId);
		if (value instanceof Boolean) {
			return (Boolean) value;
		}
		return false;
	}

	private String readStagedOverrideReason(HttpSession session, long tripId) {
		if (session == null) {
			return null;
		}
		Object value = session.getAttribute(STAGED_OVERRIDE_REASON_PREFIX + tripId);
		return value == null ? null : String.valueOf(value);
	}

	private void clearStagedSelection(HttpSession session, long tripId) {
		if (session == null) {
			return;
		}
		session.removeAttribute(STAGED_BUS_PREFIX + tripId);
		session.removeAttribute(STAGED_OVERRIDE_PREFIX + tripId);
		session.removeAttribute(STAGED_OVERRIDE_REASON_PREFIX + tripId);
	}
}

