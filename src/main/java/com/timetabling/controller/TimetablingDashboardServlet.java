package com.timetabling.controller;

import com.timetabling.dao.TimetableDAO;
import com.timetabling.model.TimetableEntry;
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
import java.util.Collections;
import java.util.List;

@WebServlet(name = "TimetablingDashboardServlet", urlPatterns = {"/timetabling/dashboard"})
public class TimetablingDashboardServlet extends HttpServlet {

	private static final String JSP_PATH = "/WEB-INF/timetabling/timetablingDashboard.jsp";
	private transient TimetableDAO timetableDAO;
	private transient TripDAO tripDAO;

	@Override
	public void init() throws ServletException {
		super.init();
		this.timetableDAO = new TimetableDAO();
		this.tripDAO = new TripDAO();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
		HttpSession session = request.getSession(false);
		if (session == null || !"TIMETABLING_STAFF".equals(session.getAttribute("userRole"))) {
			response.sendRedirect(request.getContextPath() + "/login");
			return;
		}

		List<TimetableEntry> entries;
		List<Trip> requestedTrips;
		try {
			entries = timetableDAO.findUpcomingEntries(200);
			requestedTrips = tripDAO.findRequestsForTimetabling(200);
		} catch (Exception ex) {
			entries = Collections.emptyList();
			requestedTrips = Collections.emptyList();
		}

		int publishedCount = 0;
		int submittedCount = 0;
		int activeCount = 0;
		for (TimetableEntry entry : entries) {
			if (entry == null || entry.getStatus() == null) {
				continue;
			}
			String status = entry.getStatus().toUpperCase();
			if ("PUBLISHED".equals(status) || "DRAFT".equals(status) || "RETURNED".equals(status)) {
				publishedCount++;
			} else if ("SUBMITTED".equals(status)) {
				submittedCount++;
			} else if ("ACTIVE".equals(status)) {
				activeCount++;
			}
		}

		request.setAttribute("entries", entries);
		request.setAttribute("requestedTrips", requestedTrips);
		request.setAttribute("publishedCount", publishedCount);
		request.setAttribute("submittedCount", submittedCount);
		request.setAttribute("activeCount", activeCount);
		request.getRequestDispatcher(JSP_PATH).forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
		HttpSession session = request.getSession(false);
		if (session == null || !"TIMETABLING_STAFF".equals(session.getAttribute("userRole"))) {
			response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "You must be logged in as timetabling staff.");
			return;
		}

		String action = trimToEmpty(request.getParameter("action"));
		if ("submitToManager".equalsIgnoreCase(action)) {
			handleSubmitToManager(session, request, response);
			return;
		}
		if ("scheduleFromRequest".equalsIgnoreCase(action)) {
			handleScheduleFromRequest(session, request, response);
			return;
		}

		handleCreateEntry(session, request, response);
	}

	private void handleSubmitToManager(HttpSession session,
	                                   HttpServletRequest request,
	                                   HttpServletResponse response) throws IOException {
		String creatorUsername = String.valueOf(session.getAttribute("username"));
		int submitted = timetableDAO.submitPublishedEntriesToManager(creatorUsername);
		if (submitted <= 0) {
			response.sendRedirect(request.getContextPath() + "/timetabling/dashboard?error=noEntriesReadyForSubmission");
			return;
		}

		response.sendRedirect(request.getContextPath() + "/timetabling/dashboard?success=submittedToManager");
	}

	private void handleCreateEntry(HttpSession session,
	                               HttpServletRequest request,
	                               HttpServletResponse response) throws IOException {
		String title = trimToEmpty(request.getParameter("title"));
		String department = trimToEmpty(request.getParameter("department"));
		String destination = trimToEmpty(request.getParameter("destination"));
		String departureTimeRaw = trimToEmpty(request.getParameter("departureTime"));
		String expectedPassengerRaw = trimToEmpty(request.getParameter("expectedPassengerCount"));
		String budgetRaw = trimToEmpty(request.getParameter("budgetAmount"));
		Integer expectedPassengerParsed = ValidationUtil.parseNonNegativeIntOrNull(expectedPassengerRaw);
		BigDecimal budgetParsed = ValidationUtil.parseNonNegativeMoneyOrNull(budgetRaw);
		int expectedPassengerCount = expectedPassengerParsed == null ? 0 : expectedPassengerParsed;
		BigDecimal budgetAmount = budgetParsed == null ? BigDecimal.ZERO : budgetParsed;

		if (title.isBlank() || destination.isBlank() || departureTimeRaw.isBlank()) {
			response.sendRedirect(request.getContextPath() + "/timetabling/dashboard?error=missingRequiredFields");
			return;
		}
		if (!department.isBlank() && !ValidationUtil.isAlphabeticWithSpaces(department)) {
			response.sendRedirect(request.getContextPath() + "/timetabling/dashboard?error=invalidDepartment");
			return;
		}
		if (!expectedPassengerRaw.isBlank() && expectedPassengerParsed == null) {
			response.sendRedirect(request.getContextPath() + "/timetabling/dashboard?error=invalidExpectedPassengerCount");
			return;
		}
		if (!budgetRaw.isBlank() && budgetParsed == null) {
			response.sendRedirect(request.getContextPath() + "/timetabling/dashboard?error=invalidBudgetAmount");
			return;
		}

		LocalDateTime departureTime;
		try {
			departureTime = LocalDateTime.parse(departureTimeRaw);
		} catch (DateTimeParseException ex) {
			response.sendRedirect(request.getContextPath() + "/timetabling/dashboard?error=invalidDepartureTime");
			return;
		}

		if (departureTime.isBefore(LocalDateTime.now())) {
			response.sendRedirect(request.getContextPath() + "/timetabling/dashboard?error=departureInPast");
			return;
		}

		String creatorUsername = String.valueOf(session.getAttribute("username"));
		boolean created = timetableDAO.createTimetableEntry(
			title,
			department,
			destination,
			departureTime,
			expectedPassengerCount,
			budgetAmount,
			creatorUsername
		);
		if (!created) {
			response.sendRedirect(request.getContextPath() + "/timetabling/dashboard?error=createFailed");
			return;
		}

		response.sendRedirect(request.getContextPath() + "/timetabling/dashboard?success=entryCreated");
	}

	private void handleScheduleFromRequest(HttpSession session,
	                                       HttpServletRequest request,
	                                       HttpServletResponse response) throws IOException {
		long tripRequestId = parsePositiveLongOrDefault(request.getParameter("tripRequestId"), -1L);
		String title = trimToEmpty(request.getParameter("title"));
		String department = trimToEmpty(request.getParameter("department"));
		String departureTimeRaw = trimToEmpty(request.getParameter("departureTime"));
		String budgetRaw = trimToEmpty(request.getParameter("budgetAmount"));
		BigDecimal budgetParsed = ValidationUtil.parseNonNegativeMoneyOrNull(budgetRaw);
		BigDecimal budgetAmount = budgetParsed == null ? BigDecimal.ZERO : budgetParsed;

		if (tripRequestId <= 0 || title.isBlank() || departureTimeRaw.isBlank()) {
			response.sendRedirect(request.getContextPath() + "/timetabling/dashboard?error=missingSchedulingFields");
			return;
		}
		if (!department.isBlank() && !ValidationUtil.isAlphabeticWithSpaces(department)) {
			response.sendRedirect(request.getContextPath() + "/timetabling/dashboard?error=invalidDepartment");
			return;
		}
		if (!budgetRaw.isBlank() && budgetParsed == null) {
			response.sendRedirect(request.getContextPath() + "/timetabling/dashboard?error=invalidBudgetAmount");
			return;
		}

		LocalDateTime departureTime;
		try {
			departureTime = LocalDateTime.parse(departureTimeRaw);
		} catch (DateTimeParseException ex) {
			response.sendRedirect(request.getContextPath() + "/timetabling/dashboard?error=invalidDepartureTime");
			return;
		}

		if (departureTime.isBefore(LocalDateTime.now())) {
			response.sendRedirect(request.getContextPath() + "/timetabling/dashboard?error=departureInPast");
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
			response.sendRedirect(request.getContextPath() + "/timetabling/dashboard?error=scheduleFailed");
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
