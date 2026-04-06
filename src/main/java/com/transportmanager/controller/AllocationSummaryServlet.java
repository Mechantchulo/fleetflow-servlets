package com.transportmanager.controller;

import com.transportmanager.dao.TripDAO;
import com.transportmanager.util.ManagerSessionUtil;
import com.transportmanager.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Map;

@WebServlet(name = "AllocationSummaryServlet", urlPatterns = {"/manager/trips/allocation-summary"})
public class AllocationSummaryServlet extends HttpServlet {

	private static final String ALLOCATION_SUMMARY_JSP = "/WEB-INF/manager/allocationSummary.jsp";

	private transient TripDAO tripDAO;

	@Override
	public void init() throws ServletException {
		super.init();
		this.tripDAO = new TripDAO();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
		if (!ManagerSessionUtil.isManagerLoggedIn(request)) {
			ManagerSessionUtil.redirectToLogin(request, response);
			return;
		}

		long tripId = ValidationUtil.parsePositiveLongOrDefault(request.getParameter("tripId"), -1L);
		if (tripId <= 0) {
			response.sendRedirect(request.getContextPath() + "/manager/trips/pending?error=invalidTripId");
			return;
		}

		Map<String, Object> summary;
		try {
			summary = tripDAO.getAllocationSummary(tripId);
		} catch (Exception ex) {
			response.sendRedirect(request.getContextPath() + "/manager/trips/pending?error=summaryLookupFailed");
			return;
		}

		if (summary == null || summary.isEmpty()) {
			response.sendRedirect(request.getContextPath() + "/manager/trips/pending?error=summaryNotFound");
			return;
		}

		request.setAttribute("tripId", tripId);
		request.setAttribute("summary", summary);
		request.getRequestDispatcher(ALLOCATION_SUMMARY_JSP).forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
		response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED, "Use GET to view allocation summary.");
	}
}

