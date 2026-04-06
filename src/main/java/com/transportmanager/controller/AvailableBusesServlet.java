package com.transportmanager.controller;

import com.transportmanager.dao.BusDAO;
import com.transportmanager.dao.TripDAO;
import com.transportmanager.model.Bus;
import com.transportmanager.model.Trip;
import com.transportmanager.util.ManagerSessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

@WebServlet(name = "AvailableBusesServlet", urlPatterns = {"/manager/allocation/buses"})
public class AvailableBusesServlet extends HttpServlet {

	private static final String AVAILABLE_BUSES_JSP = "/WEB-INF/manager/availableBuses.jsp";

	private transient TripDAO tripDAO;
	private transient BusDAO busDAO;

	@Override
	public void init() throws ServletException {
		super.init();
		this.tripDAO = new TripDAO();
		this.busDAO = new BusDAO();
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

		int requiredCapacity = Math.max(1, trip.getPassengerCount());

		List<Bus> availableBuses;
		try {
			availableBuses = busDAO.findAvailableBusesByCapacity(requiredCapacity);
		} catch (Exception ex) {
			response.sendRedirect(request.getContextPath() + "/manager/trips/pending?error=busLookupFailed");
			return;
		}

		if (availableBuses == null) {
			availableBuses = Collections.emptyList();
		}

		request.setAttribute("trip", trip);
		request.setAttribute("tripId", tripId);
		request.setAttribute("requiredCapacity", requiredCapacity);
		request.setAttribute("availableBuses", availableBuses);

		request.getRequestDispatcher(AVAILABLE_BUSES_JSP).forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
		response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED, "Use GET to view available buses for a trip.");
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

