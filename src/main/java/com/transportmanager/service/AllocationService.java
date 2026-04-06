package com.transportmanager.service;

import com.transportmanager.dao.BusDAO;
import com.transportmanager.dao.DriverDAO;
import com.transportmanager.dao.TripDAO;

public class AllocationService {

	private final TripDAO tripDAO;
	private final BusDAO busDAO;
	private final DriverDAO driverDAO;

	public AllocationService() {
		this.tripDAO = new TripDAO();
		this.busDAO = new BusDAO();
		this.driverDAO = new DriverDAO();
	}

	public boolean assignBus(long tripId, long busId, boolean override, String overrideReason, String managerUsername) {
		if (!override && !busDAO.isBusAvailable(busId)) {
			return false;
		}
		if (override && (overrideReason == null || overrideReason.isBlank())) {
			return false;
		}
		return tripDAO.assignBusToTrip(tripId, busId, override, overrideReason, managerUsername);
	}

	public boolean assignDriver(long tripId, long driverId, boolean override, String overrideReason, String managerUsername) {
		if (!override && !driverDAO.isDriverAvailable(driverId)) {
			return false;
		}
		if (override && (overrideReason == null || overrideReason.isBlank())) {
			return false;
		}
		return tripDAO.assignDriverToTrip(tripId, driverId, override, overrideReason, managerUsername);
	}
}

