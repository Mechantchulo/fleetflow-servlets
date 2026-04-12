package com.transportmanager.dao;

import com.transportmanager.model.Trip;
import com.transportmanager.util.DbUtil;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.Collections;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class TripDAO {

	public List<Trip> findPendingTripsSorted(int page, int size, String priority, LocalDate dateFrom, LocalDate dateTo) {
		List<Trip> trips = new ArrayList<>();
		int safePage = Math.max(1, page);
		int safeSize = Math.max(1, size);
		int offset = (safePage - 1) * safeSize;

		String sql = """
			SELECT tr.id,
			       tr.destination,
			       tr.requesting_department,
			       tr.departure_time,
			       tr.passenger_count,
			       tr.status,
			       u.full_name AS requester_name
			FROM trip_request tr
			LEFT JOIN users u ON u.id = tr.requester_id
			WHERE tr.status IN ('PENDING', 'APPROVED', 'CONFIRMED')
			  AND (? IS NULL OR DATE(tr.departure_time) >= ?)
			  AND (? IS NULL OR DATE(tr.departure_time) <= ?)
			ORDER BY tr.departure_time ASC NULLS LAST
			LIMIT ? OFFSET ?
		""";

		try (Connection connection = DbUtil.getConnection();
			 PreparedStatement statement = connection.prepareStatement(sql)) {

			setLocalDatePair(statement, 1, dateFrom);
			setLocalDatePair(statement, 3, dateTo);
			statement.setInt(5, safeSize);
			statement.setInt(6, offset);

			try (ResultSet rs = statement.executeQuery()) {
				while (rs.next()) {
					Trip trip = new Trip();
					trip.setId(rs.getLong("id"));
					trip.setDestination(rs.getString("destination"));
					trip.setDepartment(rs.getString("requesting_department"));
					trip.setRequesterName(rs.getString("requester_name"));

					Timestamp departure = rs.getTimestamp("departure_time");
					trip.setDepartureDate(departure == null ? null : departure.toLocalDateTime().toLocalDate());

					trip.setPassengerCount(rs.getInt("passenger_count"));
					trip.setStatus(rs.getString("status"));
					trip.setPriority(derivePriority(trip.getPassengerCount(), priority));
					trips.add(trip);
				}
			}
		} catch (SQLException ex) {
			return Collections.emptyList();
		}

		if (priority == null || priority.isBlank()) {
			return trips;
		}

		List<Trip> filtered = new ArrayList<>();
		for (Trip trip : trips) {
			if (priority.equalsIgnoreCase(trip.getPriority())) {
				filtered.add(trip);
			}
		}
		return filtered;
	}

	public boolean isChangeWindowOpen(long tripId, int minimumDaysBeforeDeparture) {
		String sql = """
			SELECT DATE(departure_time) >= (CURRENT_DATE + ?)
			FROM trip_request
			WHERE id = ?
		""";

		try (Connection connection = DbUtil.getConnection();
			 PreparedStatement statement = connection.prepareStatement(sql)) {
			statement.setInt(1, Math.max(0, minimumDaysBeforeDeparture));
			statement.setLong(2, tripId);
			try (ResultSet rs = statement.executeQuery()) {
				if (!rs.next()) {
					return false;
				}
				return rs.getBoolean(1);
			}
		} catch (SQLException ex) {
			return false;
		}
	}

	public boolean updateTripDecision(long tripId, String action, String managerNote, String managerUsername) {
		String sql = """
			UPDATE trip_request
			SET status = ?,
			    manager_note = ?,
			    updated_at = NOW()
			WHERE id = ?
		""";

		try (Connection connection = DbUtil.getConnection();
			 PreparedStatement statement = connection.prepareStatement(sql)) {
			statement.setString(1, normalizeDecision(action));
			statement.setString(2, managerNote);
			statement.setLong(3, tripId);
			return statement.executeUpdate() > 0;
		} catch (SQLException ex) {
			return false;
		}
	}

	public Trip findTripById(long tripId) {
		String sql = """
			SELECT tr.id,
			       tr.destination,
			       tr.requesting_department,
			       tr.departure_time,
			       tr.passenger_count,
			       tr.status,
			       u.full_name AS requester_name
			FROM trip_request tr
			LEFT JOIN users u ON u.id = tr.requester_id
			WHERE tr.id = ?
		""";

		try (Connection connection = DbUtil.getConnection();
			 PreparedStatement statement = connection.prepareStatement(sql)) {
			statement.setLong(1, tripId);
			try (ResultSet rs = statement.executeQuery()) {
				if (!rs.next()) {
					return null;
				}

				Trip trip = new Trip();
				trip.setId(rs.getLong("id"));
				trip.setDestination(rs.getString("destination"));
				trip.setDepartment(rs.getString("requesting_department"));
				trip.setRequesterName(rs.getString("requester_name"));
				Timestamp departure = rs.getTimestamp("departure_time");
				trip.setDepartureDate(departure == null ? null : departure.toLocalDateTime().toLocalDate());
				trip.setPassengerCount(rs.getInt("passenger_count"));
				trip.setStatus(rs.getString("status"));
				trip.setPriority(derivePriority(trip.getPassengerCount(), null));
				return trip;
			}
		} catch (SQLException ex) {
			return null;
		}
	}

	public boolean assignBusToTrip(long tripId, long busId, boolean override, String overrideReason, String managerUsername) {
		String sql = """
			WITH latest AS (
			    SELECT id FROM trip_assignment
			    WHERE trip_request_id = ?
			    ORDER BY id DESC
			    LIMIT 1
			)
			UPDATE trip_assignment ta
			SET vehicle_id = ?,
			    override_used = ?,
			    override_reason = ?,
			    updated_at = NOW()
			FROM latest
			WHERE ta.id = latest.id
		""";

		try (Connection connection = DbUtil.getConnection();
			 PreparedStatement statement = connection.prepareStatement(sql)) {
			statement.setLong(1, tripId);
			statement.setLong(2, busId);
			statement.setBoolean(3, override);
			statement.setString(4, overrideReason);
			return statement.executeUpdate() > 0;
		} catch (SQLException ex) {
			return false;
		}
	}

	public boolean isBusAssignedToTrip(long tripId) {
		String sql = """
			SELECT 1
			FROM trip_assignment
			WHERE trip_request_id = ?
			  AND vehicle_id IS NOT NULL
			LIMIT 1
		""";

		try (Connection connection = DbUtil.getConnection();
			 PreparedStatement statement = connection.prepareStatement(sql)) {
			statement.setLong(1, tripId);
			try (ResultSet rs = statement.executeQuery()) {
				return rs.next();
			}
		} catch (SQLException ex) {
			return false;
		}
	}

	public boolean assignDriverToTrip(long tripId, long driverId, boolean override, String overrideReason, String managerUsername) {
		Long managerId = findUserIdByEmailOrName(managerUsername);
		if (managerId == null) {
			return false;
		}

		String updateSql = """
			WITH latest AS (
			    SELECT id FROM trip_assignment
			    WHERE trip_request_id = ?
			    ORDER BY id DESC
			    LIMIT 1
			)
			UPDATE trip_assignment ta
			SET driver_id = ?,
			    assigned_by_id = ?,
			    override_used = ?,
			    override_reason = ?,
			    updated_at = NOW()
			FROM latest
			WHERE ta.id = latest.id
		""";

		try (Connection connection = DbUtil.getConnection()) {
			try (PreparedStatement update = connection.prepareStatement(updateSql)) {
				update.setLong(1, tripId);
				update.setLong(2, driverId);
				update.setLong(3, managerId);
				update.setBoolean(4, override);
				update.setString(5, overrideReason);
				if (update.executeUpdate() > 0) {
					return true;
				}
			}
			return false;
		} catch (SQLException ex) {
			return false;
		}
	}

	public boolean assignBusAndDriverToTrip(long tripId, long busId, long driverId, boolean override, String overrideReason, String managerUsername) {
		Long managerId = findUserIdByEmailOrName(managerUsername);
		if (managerId == null) {
			return false;
		}

		String updateSql = """
			WITH latest AS (
			    SELECT id FROM trip_assignment
			    WHERE trip_request_id = ?
			    ORDER BY id DESC
			    LIMIT 1
			)
			UPDATE trip_assignment ta
			SET vehicle_id = ?,
			    driver_id = ?,
			    assigned_by_id = ?,
			    assigned_at = COALESCE(assigned_at, NOW()),
			    status = 'ASSIGNED',
			    override_used = ?,
			    override_reason = ?,
			    updated_at = NOW()
			FROM latest
			WHERE ta.id = latest.id
		""";

		String insertSql = """
			INSERT INTO trip_assignment
			(trip_request_id, vehicle_id, driver_id, assigned_by_id, assigned_at, status, override_used, override_reason, created_at, updated_at)
			VALUES (?, ?, ?, ?, NOW(), 'ASSIGNED', ?, ?, NOW(), NOW())
		""";

		try (Connection connection = DbUtil.getConnection()) {
			connection.setAutoCommit(false);
			try {
				int updatedRows;
				try (PreparedStatement update = connection.prepareStatement(updateSql)) {
					update.setLong(1, tripId);
					update.setLong(2, busId);
					update.setLong(3, driverId);
					update.setLong(4, managerId);
					update.setBoolean(5, override);
					update.setString(6, overrideReason);
					updatedRows = update.executeUpdate();
				}

				if (updatedRows == 0) {
					try (PreparedStatement insert = connection.prepareStatement(insertSql)) {
						insert.setLong(1, tripId);
						insert.setLong(2, busId);
						insert.setLong(3, driverId);
						insert.setLong(4, managerId);
						insert.setBoolean(5, override);
						insert.setString(6, overrideReason);
						insert.executeUpdate();
					}
				}

				connection.commit();
				return true;
			} catch (SQLException ex) {
				connection.rollback();
				return false;
			} finally {
				connection.setAutoCommit(true);
			}
		} catch (SQLException ex) {
			return false;
		}
	}

	public boolean applyManualOverride(long tripId, String overrideType, long targetId, String reason, String managerUsername) {
		Long managerId = findUserIdByEmailOrName(managerUsername);
		if (managerId == null) {
			return false;
		}

		String sql = """
			WITH latest AS (
			    SELECT id FROM trip_assignment
			    WHERE trip_request_id = ?
			    ORDER BY id DESC
			    LIMIT 1
			)
			UPDATE trip_assignment ta
			SET override_used = TRUE,
			    override_reason = ?,
			    assigned_by_id = ?,
			    assigned_at = COALESCE(assigned_at, NOW()),
			    updated_at = NOW()
			FROM latest
			WHERE ta.id = latest.id
		""";

		try (Connection connection = DbUtil.getConnection();
			 PreparedStatement statement = connection.prepareStatement(sql)) {
			statement.setLong(1, tripId);
			statement.setString(2, reason);
			statement.setLong(3, managerId);
			return statement.executeUpdate() > 0;
		} catch (SQLException ex) {
			return false;
		}
	}

	public Map<String, Object> getManagerReportSummary(LocalDate startDate, LocalDate endDate) {
		Map<String, Object> summary = new HashMap<>();
		LocalDate safeStart = startDate == null ? LocalDate.now().withDayOfMonth(1) : startDate;
		LocalDate safeEnd = endDate == null ? LocalDate.now() : endDate;

		String tripSql = """
			SELECT COUNT(*) AS total_requests,
			       COUNT(*) FILTER (WHERE status = 'ASSIGNED') AS assigned_requests,
			       COUNT(*) FILTER (WHERE status IN ('PENDING', 'APPROVED', 'CONFIRMED')) AS open_requests,
			       COUNT(*) FILTER (WHERE status = 'REJECTED') AS rejected_requests,
			       COALESCE(SUM(passenger_count), 0) AS total_passengers
			FROM trip_request
			WHERE DATE(COALESCE(updated_at, created_at)) BETWEEN ? AND ?
		""";

		String allocationSql = """
			SELECT COUNT(*) AS total_allocations,
			       COUNT(*) FILTER (WHERE override_used = TRUE) AS override_allocations
			FROM trip_assignment
			WHERE DATE(COALESCE(assigned_at, created_at)) BETWEEN ? AND ?
		""";

		try (Connection connection = DbUtil.getConnection()) {
			try (PreparedStatement statement = connection.prepareStatement(tripSql)) {
				statement.setDate(1, Date.valueOf(safeStart));
				statement.setDate(2, Date.valueOf(safeEnd));
				try (ResultSet rs = statement.executeQuery()) {
					if (rs.next()) {
						summary.put("totalRequests", rs.getInt("total_requests"));
						summary.put("assignedRequests", rs.getInt("assigned_requests"));
						summary.put("openRequests", rs.getInt("open_requests"));
						summary.put("rejectedRequests", rs.getInt("rejected_requests"));
						summary.put("totalPassengers", rs.getInt("total_passengers"));
					}
				}
			}

			try (PreparedStatement statement = connection.prepareStatement(allocationSql)) {
				statement.setDate(1, Date.valueOf(safeStart));
				statement.setDate(2, Date.valueOf(safeEnd));
				try (ResultSet rs = statement.executeQuery()) {
					if (rs.next()) {
						summary.put("totalAllocations", rs.getInt("total_allocations"));
						summary.put("overrideAllocations", rs.getInt("override_allocations"));
					}
				}
			}
		} catch (SQLException ex) {
			return Collections.emptyMap();
		}

		summary.putIfAbsent("totalRequests", 0);
		summary.putIfAbsent("assignedRequests", 0);
		summary.putIfAbsent("openRequests", 0);
		summary.putIfAbsent("rejectedRequests", 0);
		summary.putIfAbsent("totalPassengers", 0);
		summary.putIfAbsent("totalAllocations", 0);
		summary.putIfAbsent("overrideAllocations", 0);
		return summary;
	}

	public Map<String, Object> getDriverReportSummary(LocalDate startDate, LocalDate endDate, String driverIdentity) {
		Map<String, Object> summary = new HashMap<>();
		LocalDate safeStart = startDate == null ? LocalDate.now().withDayOfMonth(1) : startDate;
		LocalDate safeEnd = endDate == null ? LocalDate.now() : endDate;
		Long driverId = findDriverIdByIdentity(driverIdentity);

		String sql = """
			SELECT COUNT(*) AS total_assigned_trips,
			       COUNT(*) FILTER (WHERE ta.status = 'ASSIGNED') AS active_assignments,
			       COUNT(*) FILTER (WHERE ta.override_used = TRUE) AS overridden_assignments,
			       COALESCE(SUM(tr.passenger_count), 0) AS passengers_handled
			FROM trip_assignment ta
			INNER JOIN trip_request tr ON tr.id = ta.trip_request_id
			WHERE DATE(COALESCE(ta.assigned_at, ta.created_at)) BETWEEN ? AND ?
			  AND (? IS NULL OR ta.driver_id = ?)
		""";

		try (Connection connection = DbUtil.getConnection();
			 PreparedStatement statement = connection.prepareStatement(sql)) {
			statement.setDate(1, Date.valueOf(safeStart));
			statement.setDate(2, Date.valueOf(safeEnd));
			if (driverId == null) {
				statement.setNull(3, java.sql.Types.BIGINT);
				statement.setNull(4, java.sql.Types.BIGINT);
			} else {
				statement.setLong(3, driverId);
				statement.setLong(4, driverId);
			}

			try (ResultSet rs = statement.executeQuery()) {
				if (rs.next()) {
					summary.put("totalAssignedTrips", rs.getInt("total_assigned_trips"));
					summary.put("activeAssignments", rs.getInt("active_assignments"));
					summary.put("overriddenAssignments", rs.getInt("overridden_assignments"));
					summary.put("passengersHandled", rs.getInt("passengers_handled"));
				}
			}
		} catch (SQLException ex) {
			return Collections.emptyMap();
		}

		summary.putIfAbsent("totalAssignedTrips", 0);
		summary.putIfAbsent("activeAssignments", 0);
		summary.putIfAbsent("overriddenAssignments", 0);
		summary.putIfAbsent("passengersHandled", 0);
		summary.put("driverScope", driverId == null ? "ALL_DRIVERS" : "CURRENT_DRIVER");
		return summary;
	}

	public List<Trip> findRequestsForTimetabling(int limit) {
		List<Trip> trips = new ArrayList<>();
		String sql = """
			SELECT tr.id,
			       tr.destination,
			       tr.requesting_department,
			       tr.departure_time,
			       tr.passenger_count,
			       tr.planned_budget,
			       tr.status,
			       tr.manager_note,
			       (tr.document_data IS NOT NULL) AS has_scheduling_document,
			       u.full_name AS requester_name
			FROM trip_request tr
			LEFT JOIN users u ON u.id = tr.requester_id
			WHERE tr.status = 'REQUESTED'
			ORDER BY tr.created_at ASC
			LIMIT ?
		""";

		try (Connection connection = DbUtil.getConnection();
			 PreparedStatement statement = connection.prepareStatement(sql)) {
			statement.setInt(1, Math.max(1, limit));
			try (ResultSet rs = statement.executeQuery()) {
				while (rs.next()) {
					Trip trip = new Trip();
					trip.setId(rs.getLong("id"));
					trip.setDestination(rs.getString("destination"));
					trip.setDepartment(rs.getString("requesting_department"));
					trip.setRequesterName(rs.getString("requester_name"));
					Timestamp departure = rs.getTimestamp("departure_time");
					trip.setDepartureDate(departure == null ? null : departure.toLocalDateTime().toLocalDate());
					trip.setPassengerCount(rs.getInt("passenger_count"));
					trip.setRequestedBudget(rs.getBigDecimal("planned_budget"));
					trip.setStatus(rs.getString("status"));
					trip.setRequestNote(rs.getString("manager_note"));
					trip.setHasSchedulingDocument(rs.getBoolean("has_scheduling_document"));
					trip.setPriority(derivePriority(trip.getPassengerCount(), null));
					trips.add(trip);
				}
			}
		} catch (SQLException ex) {
			return Collections.emptyList();
		}

		return trips;
	}

	public Trip findRequestedTripForTimetablingById(long tripId) {
		if (tripId <= 0) {
			return null;
		}

		String sql = """
			SELECT tr.id,
			       tr.destination,
			       tr.requesting_department,
			       tr.departure_time,
			       tr.passenger_count,
			       tr.planned_budget,
			       tr.status,
			       tr.manager_note,
			       (tr.document_data IS NOT NULL) AS has_scheduling_document,
			       u.full_name AS requester_name
			FROM trip_request tr
			LEFT JOIN users u ON u.id = tr.requester_id
			WHERE tr.id = ?
			  AND tr.status = 'REQUESTED'
			LIMIT 1
		""";

		try (Connection connection = DbUtil.getConnection();
			 PreparedStatement statement = connection.prepareStatement(sql)) {
			statement.setLong(1, tripId);
			try (ResultSet rs = statement.executeQuery()) {
				if (!rs.next()) {
					return null;
				}

				Trip trip = new Trip();
				trip.setId(rs.getLong("id"));
				trip.setDestination(rs.getString("destination"));
				trip.setDepartment(rs.getString("requesting_department"));
				trip.setRequesterName(rs.getString("requester_name"));
				Timestamp departure = rs.getTimestamp("departure_time");
				trip.setDepartureDate(departure == null ? null : departure.toLocalDateTime().toLocalDate());
				trip.setPassengerCount(rs.getInt("passenger_count"));
				trip.setRequestedBudget(rs.getBigDecimal("planned_budget"));
				trip.setStatus(rs.getString("status"));
				trip.setRequestNote(rs.getString("manager_note"));
				trip.setHasSchedulingDocument(rs.getBoolean("has_scheduling_document"));
				trip.setPriority(derivePriority(trip.getPassengerCount(), null));
				return trip;
			}
		} catch (SQLException ex) {
			return null;
		}
	}

	public List<Trip> findPendingClubTrips(int limit) {
		List<Trip> trips = new ArrayList<>();
		String sql = """
			SELECT tr.id,
			       tr.destination,
			       tr.departure_time,
			       tr.passenger_count,
			       tr.status,
			       u.full_name AS requester_name
			FROM trip_request tr
			LEFT JOIN users u ON u.id = tr.requester_id
			WHERE tr.status = 'PENDING'
			  AND (
			      COALESCE(tr.manager_note, '') ILIKE '%club%'
			      OR COALESCE(tr.destination, '') ILIKE 'club:%'
			  )
			ORDER BY tr.departure_time ASC NULLS LAST
			LIMIT ?
		""";

		try (Connection connection = DbUtil.getConnection();
			 PreparedStatement statement = connection.prepareStatement(sql)) {
			statement.setInt(1, Math.max(1, limit));
			try (ResultSet rs = statement.executeQuery()) {
				while (rs.next()) {
					Trip trip = new Trip();
					trip.setId(rs.getLong("id"));
					trip.setDestination(rs.getString("destination"));
					trip.setRequesterName(rs.getString("requester_name"));
					Timestamp departure = rs.getTimestamp("departure_time");
					trip.setDepartureDate(departure == null ? null : departure.toLocalDateTime().toLocalDate());
					trip.setPassengerCount(rs.getInt("passenger_count"));
					trip.setStatus(rs.getString("status"));
					trip.setPriority(derivePriority(trip.getPassengerCount(), null));
					trips.add(trip);
				}
			}
		} catch (SQLException ex) {
			return Collections.emptyList();
		}

		return trips;
	}

	public Map<String, Object> getAllocationSummary(long tripId) {
		String sql = """
			SELECT tr.id AS trip_id,
			       tr.status AS trip_status,
			       tr.destination,
			       tr.departure_time,
			       tr.passenger_count,
			       ta.id AS assignment_id,
			       ta.status AS assignment_status,
			       ta.override_used,
			       ta.override_reason,
			       v.plate_number,
			       d.full_name AS driver_name,
			       m.full_name AS manager_name
			FROM trip_request tr
			LEFT JOIN LATERAL (
			    SELECT *
			    FROM trip_assignment t
			    WHERE t.trip_request_id = tr.id
			    ORDER BY t.id DESC
			    LIMIT 1
			) ta ON TRUE
			LEFT JOIN vehicle v ON v.id = ta.vehicle_id
			LEFT JOIN users d ON d.id = ta.driver_id
			LEFT JOIN users m ON m.id = ta.assigned_by_id
			WHERE tr.id = ?
		""";

		try (Connection connection = DbUtil.getConnection();
			 PreparedStatement statement = connection.prepareStatement(sql)) {
			statement.setLong(1, tripId);
			try (ResultSet rs = statement.executeQuery()) {
				if (!rs.next()) {
					return Collections.emptyMap();
				}

				Map<String, Object> summary = new HashMap<>();
				summary.put("tripId", rs.getLong("trip_id"));
				summary.put("tripStatus", rs.getString("trip_status"));
				summary.put("destination", rs.getString("destination"));
				summary.put("departureTime", rs.getTimestamp("departure_time"));
				summary.put("passengerCount", rs.getObject("passenger_count"));
				summary.put("assignmentId", rs.getObject("assignment_id"));
				summary.put("assignmentStatus", rs.getString("assignment_status"));
				summary.put("overrideUsed", rs.getObject("override_used"));
				summary.put("overrideReason", rs.getString("override_reason"));
				summary.put("plateNumber", rs.getString("plate_number"));
				summary.put("driverName", rs.getString("driver_name"));
				summary.put("managerName", rs.getString("manager_name"));
				return summary;
			}
		} catch (SQLException ex) {
			return Collections.emptyMap();
		}
	}

	private void setLocalDatePair(PreparedStatement statement, int index, LocalDate value) throws SQLException {
		if (value == null) {
			statement.setNull(index, java.sql.Types.DATE);
			statement.setNull(index + 1, java.sql.Types.DATE);
			return;
		}
		Date sqlDate = Date.valueOf(value);
		statement.setDate(index, sqlDate);
		statement.setDate(index + 1, sqlDate);
	}

	private String derivePriority(int passengerCount, String preferred) {
		if (preferred != null && !preferred.isBlank()) {
			return preferred.toUpperCase();
		}
		if (passengerCount >= 40) {
			return "HIGH";
		}
		if (passengerCount >= 20) {
			return "MEDIUM";
		}
		return "LOW";
	}

	private String normalizeDecision(String action) {
		if (action == null) {
			return "PENDING";
		}
		String normalized = action.trim().toUpperCase();
		if ("APPROVE".equals(normalized)) {
			return "APPROVED";
		}
		if ("REJECT".equals(normalized)) {
			return "REJECTED";
		}
		if ("CONFIRM".equals(normalized)) {
			return "CONFIRMED";
		}
		return normalized;
	}

	private Long findUserIdByEmailOrName(String identity) {
		if (identity == null || identity.isBlank()) {
			return null;
		}
		String normalized = identity.trim();
		String sql = "SELECT id FROM users WHERE username = ? OR email = ? OR full_name = ? LIMIT 1";
		try (Connection connection = DbUtil.getConnection();
			 PreparedStatement statement = connection.prepareStatement(sql)) {
			statement.setString(1, normalized.toLowerCase());
			statement.setString(2, normalized);
			statement.setString(3, normalized);
			try (ResultSet rs = statement.executeQuery()) {
				if (rs.next()) {
					return rs.getLong("id");
				}
			}
		} catch (SQLException ex) {
			return null;
		}
		return null;
	}

	private Long findDriverIdByIdentity(String identity) {
		if (identity == null || identity.isBlank()) {
			return null;
		}

		String normalized = identity.trim();
		try {
			long parsedId = Long.parseLong(normalized);
			return parsedId > 0 ? parsedId : null;
		} catch (NumberFormatException ignore) {
			// Continue with email/full-name lookup.
		}

		String sql = """
			SELECT id
			FROM users
			WHERE role = 'DRIVER'
			  AND (email = ? OR full_name = ?)
			LIMIT 1
		""";

		try (Connection connection = DbUtil.getConnection();
			 PreparedStatement statement = connection.prepareStatement(sql)) {
			statement.setString(1, normalized);
			statement.setString(2, normalized);
			try (ResultSet rs = statement.executeQuery()) {
				if (rs.next()) {
					return rs.getLong("id");
				}
			}
		} catch (SQLException ex) {
			return null;
		}
		return null;
	}
}
