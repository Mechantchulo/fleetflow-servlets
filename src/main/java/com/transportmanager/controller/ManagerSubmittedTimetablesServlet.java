package com.transportmanager.controller;

import com.timetabling.dao.TimetableDAO;
import com.timetabling.model.TimetableEntry;
import com.transportmanager.util.ManagerSessionUtil;
import com.transportmanager.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

@WebServlet(name = "ManagerSubmittedTimetablesServlet", urlPatterns = {"/manager/timetables/submitted"})
public class ManagerSubmittedTimetablesServlet extends HttpServlet {

	private static final String JSP_PATH = "/WEB-INF/manager/submittedTimetables.jsp";
	private transient TimetableDAO timetableDAO;

	@Override
	public void init() throws ServletException {
		super.init();
		this.timetableDAO = new TimetableDAO();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
		if (!ManagerSessionUtil.isManagerLoggedIn(request)) {
			ManagerSessionUtil.redirectToLogin(request, response);
			return;
		}

		List<TimetableEntry> entries;
		try {
			entries = timetableDAO.findSubmittedEntries(500);
		} catch (Exception ex) {
			entries = Collections.emptyList();
		}

		request.setAttribute("submittedEntries", entries);
		request.getRequestDispatcher(JSP_PATH).forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
		if (!ManagerSessionUtil.isManagerLoggedIn(request)) {
			ManagerSessionUtil.redirectToLogin(request, response);
			return;
		}

		long entryId = ValidationUtil.parsePositiveLongOrDefault(request.getParameter("entryId"), -1L);
		if (entryId <= 0) {
			response.sendRedirect(request.getContextPath() + "/manager/timetables/submitted?error=invalidEntryId");
			return;
		}

		HttpSession session = request.getSession(false);
		String managerUsername = session == null ? null : String.valueOf(session.getAttribute("managerUsername"));
		boolean activated = timetableDAO.activateSubmittedEntry(entryId, managerUsername);
		if (!activated) {
			response.sendRedirect(request.getContextPath() + "/manager/timetables/submitted?error=activationFailed");
			return;
		}

		response.sendRedirect(request.getContextPath() + "/manager/timetables/submitted?success=entryActivated");
	}
}
