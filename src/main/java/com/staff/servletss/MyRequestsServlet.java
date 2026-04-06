package com.staff.servletss;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

class Request {
    private int id;
    private String date;
    private String driver;
    private String initials;
    private String destination;
    private String status;

    public Request(int id, String date, String driver, String initials, String destination, String status) {
        this.id = id;
        this.date = date;
        this.driver = driver;
        this.initials = initials;
        this.destination = destination;
        this.status = status;
    }

    public int getId() { return id; }
    public String getDate() { return date; }
    public String getDriver() { return driver; }
    public String getInitials() { return initials; }
    public String getDestination() { return destination; }
    public String getStatus() { return status; }
}

@WebServlet("/staff/myRequests") // ⚠️ lowercase m (VERY IMPORTANT)
public class MyRequestsServlet extends HttpServlet {

    private static List<Request> requests = new ArrayList<>();

    @Override
    public void init() {
        // Sample data
        requests.add(new Request(1, "2026-04-01", "John Doe", "JD", "Nairobi → Nakuru", "Pending"));
        requests.add(new Request(2, "2026-04-02", "Jane Smith", "JS", "Nairobi → Mombasa", "Approved"));
        requests.add(new Request(3, "2026-04-03", "Mike Lee", "ML", "Nairobi → Kisumu", "Rejected"));
        requests.add(new Request(4, "2026-04-04", "Ann Kim", "AK", "Nairobi → Eldoret", "Pending"));
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String tab = request.getParameter("tab");      // all, pending, approved, rejected
        String search = request.getParameter("search");

        List<Request> filtered = new ArrayList<>(requests);

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

        request.getRequestDispatcher("/staff/myRequests.jsp")
               .forward(request, response);
    }
}