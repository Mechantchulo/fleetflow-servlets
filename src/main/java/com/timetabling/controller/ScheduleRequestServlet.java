package com.timetabling.controller;

import com.timetabling.dao.TimetableDAO;
import com.transportmanager.dao.TripDAO;
import com.transportmanager.model.Trip;
import com.transportmanager.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;

@WebServlet(name = "ScheduleRequestServlet", urlPatterns = {"/timetabling/requests/schedule"})
public class ScheduleRequestServlet extends HttpServlet {

	private static final String JSP_PATH = "/WEB-INF/timetabling/scheduleRequest.jsp";
	private transient TripDAO tripDAO;
	private transient TimetableDAO timetableDAO;

	@Override
	public void init() throws ServletException {
		super.init();
		this.tripDAO = new TripDAO();
		this.timetableDAO = new TimetableDAO();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
		HttpSession session = request.getSession(false);
		if (session == null || !"TIMETABLING_STAFF".equals(session.getAttribute("userRole"))) {
			response.sendRedirect(request.getContextPath() + "/login");
			return;
		}

		long tripRequestId = parsePositiveLongOrDefault(request.getParameter("id"), -1L);
		if (tripRequestId <= 0) {
			response.sendRedirect(request.getContextPath() + "/timetabling/dashboard?error=invalidRequestId");
			return;
		}

		Trip selectedRequest = tripDAO.findRequestedTripForTimetablingById(tripRequestId);
		if (selectedRequest == null) {
			response.sendRedirect(request.getContextPath() + "/timetabling/dashboard?error=requestNotFoundOrAlreadyScheduled");
			return;
		}

		request.setAttribute("selectedRequest", selectedRequest);
		request.getRequestDispatcher(JSP_PATH).forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
		HttpSession session = request.getSession(false);
		if (session == null || !"TIMETABLING_STAFF".equals(session.getAttribute("userRole"))) {
			response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "You must be logged in as timetabling staff.");
			return;
		}

		long tripRequestId = parsePositiveLongOrDefault(request.getParameter("tripRequestId"), -1L);
		String title = trimToEmpty(request.getParameter("title"));
		String department = trimToEmpty(request.getParameter("department"));
		String departureTimeRaw = trimToEmpty(request.getParameter("departureTime"));
		String budgetRaw = trimToEmpty(request.getParameter("budgetAmount"));
		BigDecimal budgetParsed = ValidationUtil.parseNonNegativeMoneyOrNull(budgetRaw);
		BigDecimal budgetAmount = budgetParsed == null ? BigDecimal.ZERO : budgetParsed;

		if (tripRequestId <= 0 || title.isBlank() || departureTimeRaw.isBlank()) {
			response.sendRedirect(request.getContextPath() + "/timetabling/requests/schedule?id=" + tripRequestId + "&error=missingSchedulingFields");
			return;
		}
		if (!department.isBlank() && !ValidationUtil.isAlphabeticWithSpaces(department)) {
			response.sendRedirect(request.getContextPath() + "/timetabling/requests/schedule?id=" + tripRequestId + "&error=invalidDepartment");
			return;
		}
		if (!budgetRaw.isBlank() && budgetParsed == null) {
			response.sendRedirect(request.getContextPath() + "/timetabling/requests/schedule?id=" + tripRequestId + "&error=invalidBudgetAmount");
			return;
		}

		LocalDateTime departureTime;
		try {
			departureTime = LocalDateTime.parse(departureTimeRaw);
		} catch (DateTimeParseException ex) {
			response.sendRedirect(request.getContextPath() + "/timetabling/requests/schedule?id=" + tripRequestId + "&error=invalidDepartureTime");
			return;
		}

		if (departureTime.isBefore(LocalDateTime.now())) {
			response.sendRedirect(request.getContextPath() + "/timetabling/requests/schedule?id=" + tripRequestId + "&error=departureInPast");
			return;
		}

		String creatorUsername = String.valueOf(session.getAttribute("username"));
		boolean scheduled = timetableDAO.scheduleFromStaffRequest(
				tripRequestId,
				title,
				department,
				departureTime,
				budgetAmount,
				creatorUsername
		);
		if (!scheduled) {
			response.sendRedirect(request.getContextPath() + "/timetabling/requests/schedule?id=" + tripRequestId + "&error=scheduleFailed");
			return;
		}

		response.sendRedirect(request.getContextPath() + "/timetabling/dashboard?success=requestScheduled");
	}

	private long parsePositiveLongOrDefault(String raw, long defaultValue) {
		if (raw == null || raw.isBlank()) {
			return defaultValue;
		}
		try {
			long value = Long.parseLong(raw.trim());
			return value > 0 ? value : defaultValue;
		} catch (NumberFormatException ex) {
			return defaultValue;
		}
	}

	private String trimToEmpty(String value) {
		return value == null ? "" : value.trim();
	}
}
