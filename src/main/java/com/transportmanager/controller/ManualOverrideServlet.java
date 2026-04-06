package com.transportmanager.controller;

import com.transportmanager.dao.TripDAO;
import com.transportmanager.util.ManagerSessionUtil;
import com.transportmanager.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "ManualOverrideServlet", urlPatterns = {"/manager/allocation/override"})
public class ManualOverrideServlet extends HttpServlet {

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

		long tripId = ValidationUtil.parsePositiveLongOrDefault(request.getParameter("tripId"), -1L);
		String overrideType = ValidationUtil.normalizeOverrideType(request.getParameter("overrideType"));
		long targetId = ValidationUtil.parsePositiveLongOrDefault(request.getParameter("targetId"), -1L);
		String reason = ValidationUtil.trimToNull(request.getParameter("reason"));

		if (tripId <= 0 || overrideType == null || reason == null) {
			response.sendRedirect(request.getContextPath() + "/manager/trips/pending?error=invalidOverrideInput");
			return;
		}

		if (("BUS".equals(overrideType) || "DRIVER".equals(overrideType)) && targetId <= 0) {
			response.sendRedirect(request.getContextPath() + "/manager/trips/pending?error=invalidOverrideTarget");
			return;
		}

		HttpSession session = request.getSession(false);
		String managerUsername = session == null ? "unknown" : String.valueOf(session.getAttribute("managerUsername"));

		boolean overridden;
		try {
			overridden = tripDAO.applyManualOverride(tripId, overrideType, targetId, reason, managerUsername);
		} catch (Exception ex) {
			response.sendRedirect(request.getContextPath() + "/manager/trips/pending?error=overrideFailed");
			return;
		}

		if (!overridden) {
			response.sendRedirect(request.getContextPath() + "/manager/trips/pending?error=overrideNotSaved");
			return;
		}

		response.sendRedirect(request.getContextPath() + "/manager/trips/allocation-summary?tripId=" + tripId + "&success=overrideSaved");
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
		response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED, "Use POST to submit manual overrides.");
	}
}

