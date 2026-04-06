package com.transportmanager.service;

import com.transportmanager.dao.TripDAO;
import com.transportmanager.model.Trip;
import com.transportmanager.util.ValidationUtil;

import java.time.LocalDate;
import java.util.List;

public class TripQueueService {

	private final TripDAO tripDAO;

	public TripQueueService() {
		this.tripDAO = new TripDAO();
	}

	public List<Trip> getPendingTrips(String pageRaw, String sizeRaw, String priorityRaw, String dateFromRaw, String dateToRaw) {
		int page = ValidationUtil.parseRangeIntOrDefault(pageRaw, 1, 1, Integer.MAX_VALUE);
		int size = ValidationUtil.parseRangeIntOrDefault(sizeRaw, 10, 1, 100);
		String priority = ValidationUtil.sanitizePriority(priorityRaw);
		LocalDate dateFrom = ValidationUtil.parseDateOrNull(dateFromRaw);
		LocalDate dateTo = ValidationUtil.parseDateOrNull(dateToRaw);

		return tripDAO.findPendingTripsSorted(page, size, priority, dateFrom, dateTo);
	}
}

