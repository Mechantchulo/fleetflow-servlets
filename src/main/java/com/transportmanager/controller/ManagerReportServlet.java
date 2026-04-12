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
import java.time.LocalDate;
import java.util.Map;

@WebServlet(name = "ManagerReportServlet", urlPatterns = {"/manager/reports/summary"})
public class ManagerReportServlet extends HttpServlet {

	private static final String MANAGER_REPORT_JSP = "/WEB-INF/manager/managerReport.jsp";
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

		LocalDate defaultStart = LocalDate.now().withDayOfMonth(1);
		LocalDate defaultEnd = LocalDate.now();

		LocalDate startDate = ValidationUtil.parseDateOrNull(request.getParameter("startDate"));
		LocalDate endDate = ValidationUtil.parseDateOrNull(request.getParameter("endDate"));

		if (startDate == null) {
			startDate = defaultStart;
		}
		if (endDate == null) {
			endDate = defaultEnd;
		}

		if (startDate.isAfter(endDate)) {
			response.sendError(HttpServletResponse.SC_BAD_REQUEST, "startDate cannot be after endDate.");
			return;
		}

		Map<String, Object> summary = tripDAO.getManagerReportSummary(startDate, endDate);

		request.setAttribute("reportStartDate", startDate);
		request.setAttribute("reportEndDate", endDate);
		request.setAttribute("reportSummary", summary);
		request.getRequestDispatcher(MANAGER_REPORT_JSP).forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
		response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED, "Use GET for manager reports.");
	}
}
