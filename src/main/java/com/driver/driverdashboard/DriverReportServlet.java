package com.driver.driverdashboard;

import com.transportmanager.dao.TripDAO;
import com.transportmanager.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;
import java.util.Map;

@WebServlet(name = "DriverReportServlet", urlPatterns = {"/driver/reports/summary"})
public class DriverReportServlet extends HttpServlet {

	private static final String DRIVER_REPORT_JSP = "/WEB-INF/driver/driverReport.jsp";
	private transient TripDAO tripDAO;

	@Override
	public void init() throws ServletException {
		super.init();
		this.tripDAO = new TripDAO();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
		HttpSession session = request.getSession(false);
		if (session == null || !"DRIVER".equals(session.getAttribute("userRole"))) {
			response.sendRedirect(request.getContextPath() + "/login");
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

		String identityFromRequest = trimToNull(request.getParameter("driverIdentity"));
		String sessionIdentity = String.valueOf(session.getAttribute("username"));
		String driverIdentity = identityFromRequest == null ? sessionIdentity : identityFromRequest;
		Map<String, Object> summary = tripDAO.getDriverReportSummary(startDate, endDate, driverIdentity);

		request.setAttribute("reportStartDate", startDate);
		request.setAttribute("reportEndDate", endDate);
		request.setAttribute("reportSummary", summary);
		request.getRequestDispatcher(DRIVER_REPORT_JSP).forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
		response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED, "Use GET for driver reports.");
	}

	private String trimToNull(String raw) {
		if (raw == null) {
			return null;
		}
		String value = raw.trim();
		return value.isEmpty() ? null : value;
	}
}
