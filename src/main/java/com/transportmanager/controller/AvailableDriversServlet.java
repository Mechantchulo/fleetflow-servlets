package com.transportmanager.controller;

import com.transportmanager.dao.DriverDAO;
import com.transportmanager.dao.TripDAO;
import com.transportmanager.model.Driver;
import com.transportmanager.model.Trip;
import com.transportmanager.util.ManagerSessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

@WebServlet(name = "AvailableDriversServlet", urlPatterns = {"/manager/allocation/drivers"})
public class AvailableDriversServlet extends HttpServlet {

	private static final String AVAILABLE_DRIVERS_JSP = "/WEB-INF/manager/availableDrivers.jsp";
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
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
		if (!ManagerSessionUtil.isManagerLoggedIn(request)) {
			ManagerSessionUtil.redirectToLogin(request, response);
			return;
		}

		long tripId = parseLongOrDefault(request.getParameter("tripId"), -1L);
		if (tripId <= 0) {
			response.sendRedirect(request.getContextPath() + "/manager/trips/pending?error=invalidTripId");
			return;
		}

		Trip trip;
		try {
			trip = tripDAO.findTripById(tripId);
		} catch (Exception ex) {
			response.sendRedirect(request.getContextPath() + "/manager/trips/pending?error=tripLookupFailed");
			return;
		}

		if (trip == null) {
			response.sendRedirect(request.getContextPath() + "/manager/trips/pending?error=tripNotFound");
			return;
		}

		HttpSession session = request.getSession(false);
		Object stagedBus = session == null ? null : session.getAttribute(STAGED_BUS_PREFIX + tripId);
		if (!(stagedBus instanceof Long)) {
			response.sendRedirect(request.getContextPath() + "/manager/allocation/buses?tripId=" + tripId + "&error=assignBusFirst");
			return;
		}

		List<Driver> availableDrivers;
		try {
			availableDrivers = driverDAO.findAvailableDriversForTrip(tripId);
		} catch (Exception ex) {
			response.sendRedirect(request.getContextPath() + "/manager/trips/pending?error=driverLookupFailed");
			return;
		}

		if (availableDrivers == null) {
			availableDrivers = Collections.emptyList();
		}

		request.setAttribute("trip", trip);
		request.setAttribute("tripId", tripId);
		request.setAttribute("selectedBusId", stagedBus);
		request.setAttribute("override", session.getAttribute(STAGED_OVERRIDE_PREFIX + tripId));
		request.setAttribute("overrideReason", session.getAttribute(STAGED_OVERRIDE_REASON_PREFIX + tripId));
		request.setAttribute("availableDrivers", availableDrivers);

		request.getRequestDispatcher(AVAILABLE_DRIVERS_JSP).forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
		response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED, "Use GET to view available drivers for a trip.");
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
}

