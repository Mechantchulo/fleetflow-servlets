package com.timetabling.controller;

import com.timetabling.dao.TimetableDAO;
import com.timetabling.model.TimetableEntry;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.pdmodel.font.PDType1Font;
import org.apache.pdfbox.pdmodel.font.Standard14Fonts;

import java.io.IOException;
import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@WebServlet(name = "TimetablePdfExportServlet", urlPatterns = {"/timetabling/export/pdf", "/manager/timetables/export/pdf"})
public class TimetablePdfExportServlet extends HttpServlet {

	private static final float PAGE_MARGIN = 36f;
	private static final float PAGE_WIDTH = PDRectangle.A4.getWidth();
	private static final float PAGE_HEIGHT = PDRectangle.A4.getHeight();
	private static final float CONTENT_WIDTH = PAGE_WIDTH - (2 * PAGE_MARGIN);

	private static final DateTimeFormatter DT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
	private static final DecimalFormat MONEY = new DecimalFormat("#,##0.00");

	private static final PDType1Font FONT_BOLD = new PDType1Font(Standard14Fonts.FontName.HELVETICA_BOLD);
	private static final PDType1Font FONT_REGULAR = new PDType1Font(Standard14Fonts.FontName.HELVETICA);

	private transient TimetableDAO timetableDAO;

	@Override
	public void init() throws ServletException {
		super.init();
		this.timetableDAO = new TimetableDAO();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
		HttpSession session = request.getSession(false);
		if (session == null) {
			response.sendRedirect(request.getContextPath() + "/login");
			return;
		}

		String role = String.valueOf(session.getAttribute("userRole"));
		if (!("TIMETABLING_STAFF".equals(role) || "TRANSPORT_MANAGER".equals(role))) {
			response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only timetabling staff or transport manager can export this PDF.");
			return;
		}

		List<TimetableEntry> entries;
		try {
			entries = timetableDAO.findEntriesForPdf();
		} catch (Exception ex) {
			entries = Collections.emptyList();
		}

		String scope = request.getParameter("scope");
		if ("submitted".equalsIgnoreCase(scope)) {
			List<TimetableEntry> filtered = new ArrayList<>();
			for (TimetableEntry entry : entries) {
				if (entry != null && "SUBMITTED".equalsIgnoreCase(entry.getStatus())) {
					filtered.add(entry);
				}
			}
			entries = filtered;
		}

		response.setContentType("application/pdf");
		response.setHeader("Content-Disposition", "attachment; filename=ATMS_Timetable_Report.pdf");

		try (PDDocument document = new PDDocument()) {
			PDPage page = new PDPage(PDRectangle.A4);
			document.addPage(page);
			PDPageContentStream cs = new PDPageContentStream(document, page);

			float y = drawHeaderBlock(cs, role, entries.size(), scope);
			y = drawSummaryStrip(cs, entries, y);
			y = drawTableHeader(cs, y);

			for (TimetableEntry entry : entries) {
				if (y < 90) {
					cs.close();
					page = new PDPage(PDRectangle.A4);
					document.addPage(page);
					cs = new PDPageContentStream(document, page);
					y = drawHeaderBlock(cs, role, entries.size(), scope);
					y = drawTableHeader(cs, y);
				}
				y = drawEntryRow(cs, entry, y);
			}

			drawFooter(cs, entries, y);
			cs.close();
			document.save(response.getOutputStream());
		} catch (Exception ex) {
			log("PDF generation failed for /timetabling/export/pdf", ex);
			response.reset();
			response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "PDF generation failed.");
		}
	}

	private float drawHeaderBlock(PDPageContentStream cs, String role, int count, String scope) throws IOException {
		float topY = PAGE_HEIGHT - PAGE_MARGIN;
		float boxHeight = 72f;

		setNonStrokeRgb(cs, 16, 122, 87); // Egerton green
		cs.addRect(PAGE_MARGIN, topY - boxHeight, CONTENT_WIDTH, boxHeight);
		cs.fill();

		drawText(cs, FONT_BOLD, 18, 50, topY - 24, 255, 255, 255, "ATMS Timetable Report");
		drawText(cs, FONT_REGULAR, 10, 50, topY - 42, 232, 249, 239,
			"Role: " + role + " | Scope: " + (scope == null ? "all" : scope) + " | Entries: " + count);

		return topY - boxHeight - 16;
	}

	private float drawSummaryStrip(PDPageContentStream cs, List<TimetableEntry> entries, float y) throws IOException {
		BigDecimal totalBudget = BigDecimal.ZERO;
		int totalPassengers = 0;
		for (TimetableEntry entry : entries) {
			if (entry == null) {
				continue;
			}
			totalPassengers += Math.max(0, entry.getExpectedPassengerCount());
			BigDecimal budget = entry.getBudgetAmount() == null ? BigDecimal.ZERO : entry.getBudgetAmount();
			totalBudget = totalBudget.add(budget);
		}

		setNonStrokeRgb(cs, 245, 252, 248);
		cs.addRect(PAGE_MARGIN, y - 30, CONTENT_WIDTH, 26);
		cs.fill();

		drawText(cs, FONT_BOLD, 10, 50, y - 20, 16, 84, 63,
			"Total Passengers: " + totalPassengers + "    Total Budget (KES): " + MONEY.format(totalBudget));
		return y - 40;
	}

	private float drawTableHeader(PDPageContentStream cs, float y) throws IOException {
		setNonStrokeRgb(cs, 220, 242, 232);
		cs.addRect(PAGE_MARGIN, y - 16, CONTENT_WIDTH, 16);
		cs.fill();

		drawText(cs, FONT_BOLD, 8, 50, y - 12, 16, 84, 63, "ID");
		drawText(cs, FONT_BOLD, 8, 74, y - 12, 16, 84, 63, "TITLE");
		drawText(cs, FONT_BOLD, 8, 174, y - 12, 16, 84, 63, "DEPT");
		drawText(cs, FONT_BOLD, 8, 254, y - 12, 16, 84, 63, "DESTINATION");
		drawText(cs, FONT_BOLD, 8, 364, y - 12, 16, 84, 63, "DEPARTURE");
		drawText(cs, FONT_BOLD, 8, 446, y - 12, 16, 84, 63, "PAX");
		drawText(cs, FONT_BOLD, 8, 482, y - 12, 16, 84, 63, "BUDGET");
		drawText(cs, FONT_BOLD, 8, 548, y - 12, 16, 84, 63, "STATUS");
		return y - 20;
	}

	private float drawEntryRow(PDPageContentStream cs, TimetableEntry entry, float y) throws IOException {
		String id = String.valueOf(entry.getId());
		String title = trim(entry.getTitle(), 20);
		String dept = trim(entry.getDepartment(), 14);
		String destination = trim(entry.getDestination(), 20);
		String departure = formatDeparture(entry.getDepartureTime());
		String pax = String.valueOf(Math.max(0, entry.getExpectedPassengerCount()));
		String budget = MONEY.format(entry.getBudgetAmount() == null ? BigDecimal.ZERO : entry.getBudgetAmount());
		String status = trim(entry.getStatus(), 10);

		setNonStrokeRgb(cs, 255, 255, 255);
		cs.addRect(PAGE_MARGIN, y - 14, CONTENT_WIDTH, 14);
		cs.fill();

		drawText(cs, FONT_REGULAR, 8, 50, y - 10, 21, 33, 54, id);
		drawText(cs, FONT_REGULAR, 8, 74, y - 10, 21, 33, 54, title);
		drawText(cs, FONT_REGULAR, 8, 174, y - 10, 21, 33, 54, dept);
		drawText(cs, FONT_REGULAR, 8, 254, y - 10, 21, 33, 54, destination);
		drawText(cs, FONT_REGULAR, 8, 364, y - 10, 21, 33, 54, departure);
		drawText(cs, FONT_REGULAR, 8, 446, y - 10, 21, 33, 54, pax);
		drawText(cs, FONT_REGULAR, 8, 482, y - 10, 21, 33, 54, budget);
		drawText(cs, FONT_BOLD, 8, 548, y - 10, 16, 122, 87, status);

		setStrokeRgb(cs, 224, 232, 242);
		cs.moveTo(PAGE_MARGIN, y - 14);
		cs.lineTo(PAGE_MARGIN + CONTENT_WIDTH, y - 14);
		cs.stroke();

		return y - 16;
	}

	private void drawFooter(PDPageContentStream cs, List<TimetableEntry> entries, float y) throws IOException {
		String note = "Prepared for Egerton University transport operations. Entries listed: " + entries.size();
		float footerY = Math.max(36, y - 12);
		drawText(cs, FONT_REGULAR, 9, 50, footerY, 60, 90, 78, note);
	}

	private void drawText(PDPageContentStream cs,
	                      PDType1Font font,
	                      float size,
	                      float x,
	                      float y,
	                      int r,
	                      int g,
	                      int b,
	                      String value) throws IOException {
		cs.beginText();
		cs.setFont(font, size);
		cs.setNonStrokingColor(normalizeColor(r), normalizeColor(g), normalizeColor(b));
		cs.newLineAtOffset(x, y);
		cs.showText(sanitizePdfText(value));
		cs.endText();
	}

	private String formatDeparture(LocalDateTime departureTime) {
		if (departureTime == null) {
			return "-";
		}
		return departureTime.format(DT);
	}

	private String trim(String value, int limit) {
		if (value == null || value.isBlank()) {
			return "-";
		}
		String v = value.trim();
		if (v.length() <= limit) {
			return v;
		}
		return v.substring(0, Math.max(0, limit - 3)) + "...";
	}

	private String sanitizePdfText(String raw) {
		if (raw == null) {
			return "";
		}
		StringBuilder safe = new StringBuilder(raw.length());
		for (int i = 0; i < raw.length(); i++) {
			char c = raw.charAt(i);
			if (c >= 32 && c <= 126) {
				safe.append(c);
			} else {
				safe.append('?');
			}
		}
		return safe.toString();
	}

	private void setNonStrokeRgb(PDPageContentStream cs, int r, int g, int b) throws IOException {
		cs.setNonStrokingColor(normalizeColor(r), normalizeColor(g), normalizeColor(b));
	}

	private void setStrokeRgb(PDPageContentStream cs, int r, int g, int b) throws IOException {
		cs.setStrokingColor(normalizeColor(r), normalizeColor(g), normalizeColor(b));
	}

	private float normalizeColor(int value) {
		int clamped = Math.max(0, Math.min(255, value));
		return clamped / 255f;
	}
}
