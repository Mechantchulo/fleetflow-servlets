package com.staff.servletss;

import com.staff.dao.StaffTripDAO;
import com.staff.model.Request;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/staff/myRequests") // ⚠️ lowercase m (VERY IMPORTANT)
public class MyRequestsServlet extends HttpServlet {

    private transient StaffTripDAO staffTripDAO;

    @Override
    public void init() {
        this.staffTripDAO = new StaffTripDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !"STAFF".equals(session.getAttribute("userRole"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        String staffUsername = String.valueOf(session.getAttribute("username"));
        String tab = request.getParameter("tab");      // all, pending, approved, rejected
        String search = request.getParameter("search");

        List<Request> requests = staffTripDAO.findRequestsByStaff(staffUsername);
        List<Request> filtered = requests;

        // 🔍 Filter by tab (status)
        if (tab != null && !tab.equals("all")) {
            filtered = filtered.stream()
                    .filter(r -> r.getStatus().equalsIgnoreCase(tab))
                    .collect(Collectors.toList());
        }

        // 🔎 Search filter
        if (search != null && !search.trim().isEmpty()) {
            String query = search.toLowerCase();

            filtered = filtered.stream()
                    .filter(r ->
                            String.valueOf(r.getId()).contains(query) ||
                            r.getDriver().toLowerCase().contains(query) ||
                            r.getDestination().toLowerCase().contains(query)
                    )
                    .collect(Collectors.toList());
        }

        // 📊 Counts for tabs
        long pendingCount = requests.stream()
                .filter(r -> r.getStatus().equalsIgnoreCase("Pending")).count();

        long approvedCount = requests.stream()
                .filter(r -> r.getStatus().equalsIgnoreCase("Approved")).count();

        long rejectedCount = requests.stream()
                .filter(r -> r.getStatus().equalsIgnoreCase("Rejected")).count();

        // Send data to JSP
        request.setAttribute("requests", filtered);
        request.setAttribute("activeTab", tab == null ? "all" : tab);
        request.setAttribute("search", search == null ? "" : search);

        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("approvedCount", approvedCount);
        request.setAttribute("rejectedCount", rejectedCount);

        request.getRequestDispatcher("/WEB-INF/staff/myRequests.jsp")
               .forward(request, response);
    }
}
