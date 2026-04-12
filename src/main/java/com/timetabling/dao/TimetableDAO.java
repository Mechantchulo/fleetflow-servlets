package com.timetabling.dao;

import com.timetabling.model.TimetableEntry;
import com.transportmanager.util.DbUtil;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class TimetableDAO {

	public List<TimetableEntry> findUpcomingEntries(int limit) {
		List<TimetableEntry> entries = new ArrayList<>();
		String sql = """
			SELECT te.id,
			       te.title,
			       te.department,
			       te.destination,
			       te.departure_time,
			       te.expected_passenger_count,
			       te.budget_amount,
			       te.status,
			       te.submitted_at,
			       te.source_trip_request_id,
			       u.full_name AS created_by_name
			FROM timetable_entry te
			LEFT JOIN users u ON u.id = te.created_by_id
			WHERE te.departure_time >= NOW() - INTERVAL '1 day'
			ORDER BY te.departure_time ASC
			LIMIT ?
		""";

		try (Connection connection = DbUtil.getConnection();
			 PreparedStatement statement = connection.prepareStatement(sql)) {
			statement.setInt(1, Math.max(1, limit));
			try (ResultSet rs = statement.executeQuery()) {
				while (rs.next()) {
					entries.add(mapEntry(rs));
				}
			}
		} catch (SQLException ex) {
			return Collections.emptyList();
		}

		return entries;
	}

	public List<TimetableEntry> findSubmittedEntries(int limit) {
		List<TimetableEntry> entries = new ArrayList<>();
		String sql = """
			SELECT te.id,
			       te.title,
			       te.department,
			       te.destination,
			       te.departure_time,
			       te.expected_passenger_count,
			       te.budget_amount,
			       te.status,
			       te.submitted_at,
			       te.source_trip_request_id,
			       u.full_name AS created_by_name
			FROM timetable_entry te
			LEFT JOIN users u ON u.id = te.created_by_id
			WHERE te.status = 'SUBMITTED'
			ORDER BY te.departure_time ASC
			LIMIT ?
		""";

		try (Connection connection = DbUtil.getConnection();
			 PreparedStatement statement = connection.prepareStatement(sql)) {
			statement.setInt(1, Math.max(1, limit));
			try (ResultSet rs = statement.executeQuery()) {
				while (rs.next()) {
					entries.add(mapEntry(rs));
				}
			}
		} catch (SQLException ex) {
			return Collections.emptyList();
		}

		return entries;
	}

	public List<TimetableEntry> findEntriesForPdf() {
		List<TimetableEntry> entries = new ArrayList<>();
		String sql = """
			SELECT te.id,
			       te.title,
			       te.department,
			       te.destination,
			       te.departure_time,
			       te.expected_passenger_count,
			       te.budget_amount,
			       te.status,
			       te.submitted_at,
			       te.source_trip_request_id,
			       u.full_name AS created_by_name
			FROM timetable_entry te
			LEFT JOIN users u ON u.id = te.created_by_id
			ORDER BY te.departure_time ASC
		""";

		try (Connection connection = DbUtil.getConnection();
			 PreparedStatement statement = connection.prepareStatement(sql);
			 ResultSet rs = statement.executeQuery()) {
			while (rs.next()) {
				entries.add(mapEntry(rs));
			}
		} catch (SQLException ex) {
			return Collections.emptyList();
		}
		return entries;
	}

	public boolean createTimetableEntry(String title,
	                                    String department,
	                                    String destination,
	                                    LocalDateTime departureTime,
	                                    int expectedPassengerCount,
	                                    BigDecimal budgetAmount,
	                                    String creatorUsername) {
		Long creatorId = findUserIdByUsername(creatorUsername);
		if (creatorId == null) {
			return false;
		}

		String sql = """
			INSERT INTO timetable_entry
			(title, department, destination, departure_time, expected_passenger_count, budget_amount, status, created_by_id, created_at, updated_at)
			VALUES (?, ?, ?, ?, ?, ?, 'PUBLISHED', ?, NOW(), NOW())
		""";

		try (Connection connection = DbUtil.getConnection();
			 PreparedStatement statement = connection.prepareStatement(sql)) {
			statement.setString(1, title);
			statement.setString(2, department);
			statement.setString(3, destination);
			statement.setTimestamp(4, Timestamp.valueOf(departureTime));
			statement.setInt(5, Math.max(0, expectedPassengerCount));
			statement.setBigDecimal(6, sanitizeBudget(budgetAmount));
			statement.setLong(7, creatorId);
			return statement.executeUpdate() > 0;
		} catch (SQLException ex) {
			return false;
		}
	}

	public boolean scheduleFromStaffRequest(long tripRequestId,
	                                        String title,
	                                        String department,
	                                        LocalDateTime departureTime,
	                                        BigDecimal budgetAmount,
	                                        String creatorUsername) {
		Long creatorId = findUserIdByUsername(creatorUsername);
		if (creatorId == null || tripRequestId <= 0) {
			return false;
		}

		String fetchRequest = """
			SELECT destination, passenger_count, requesting_department
			FROM trip_request
			WHERE id = ?
			  AND status = 'REQUESTED'
		""";

		String insertEntry = """
			INSERT INTO timetable_entry
			(title, department, destination, departure_time, expected_passenger_count, budget_amount, status, created_by_id, source_trip_request_id, created_at, updated_at)
			VALUES (?, ?, ?, ?, ?, ?, 'PUBLISHED', ?, ?, NOW(), NOW())
		""";

		String updateRequest = """
			UPDATE trip_request
			SET status = 'SCHEDULED',
			    departure_time = ?,
			    requesting_department = ?,
			    planned_budget = ?,
			    updated_at = NOW()
			WHERE id = ?
		""";

		try (Connection connection = DbUtil.getConnection()) {
			connection.setAutoCommit(false);
			try {
				String destination;
				String requestDepartment;
				int passengers;
				try (PreparedStatement fetch = connection.prepareStatement(fetchRequest)) {
					fetch.setLong(1, tripRequestId);
					try (ResultSet rs = fetch.executeQuery()) {
						if (!rs.next()) {
							connection.rollback();
							return false;
						}
						destination = rs.getString("destination");
						passengers = rs.getInt("passenger_count");
						requestDepartment = rs.getString("requesting_department");
					}
				}
				String effectiveDepartment = (department == null || department.isBlank()) ? requestDepartment : department;

				try (PreparedStatement insert = connection.prepareStatement(insertEntry)) {
					insert.setString(1, title);
					insert.setString(2, effectiveDepartment);
					insert.setString(3, destination);
					insert.setTimestamp(4, Timestamp.valueOf(departureTime));
					insert.setInt(5, Math.max(0, passengers));
					insert.setBigDecimal(6, sanitizeBudget(budgetAmount));
					insert.setLong(7, creatorId);
					insert.setLong(8, tripRequestId);
					insert.executeUpdate();
				}

				try (PreparedStatement update = connection.prepareStatement(updateRequest)) {
					update.setTimestamp(1, Timestamp.valueOf(departureTime));
					update.setString(2, effectiveDepartment);
					update.setBigDecimal(3, sanitizeBudget(budgetAmount));
					update.setLong(4, tripRequestId);
					update.executeUpdate();
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

	public int submitPublishedEntriesToManager(String submitterUsername) {
		Long submitterId = findUserIdByUsername(submitterUsername);
		if (submitterId == null) {
			return 0;
		}

		String updateEntries = """
			UPDATE timetable_entry
			SET status = 'SUBMITTED',
			    submitted_at = NOW(),
			    submitted_by_id = ?,
			    updated_at = NOW()
			WHERE status IN ('PUBLISHED', 'DRAFT', 'RETURNED')
		""";

		String updateRequests = """
			UPDATE trip_request tr
			SET status = 'SUBMITTED',
			    updated_at = NOW()
			FROM timetable_entry te
			WHERE te.source_trip_request_id = tr.id
			  AND te.status = 'SUBMITTED'
			  AND tr.status IN ('SCHEDULED', 'REQUESTED')
		""";

		try (Connection connection = DbUtil.getConnection()) {
			connection.setAutoCommit(false);
			try (PreparedStatement updateEntriesStmt = connection.prepareStatement(updateEntries);
				 PreparedStatement updateRequestsStmt = connection.prepareStatement(updateRequests)) {
				updateEntriesStmt.setLong(1, submitterId);
				int updatedEntries = updateEntriesStmt.executeUpdate();
				updateRequestsStmt.executeUpdate();
				connection.commit();
				return updatedEntries;
			} catch (SQLException ex) {
				connection.rollback();
				return 0;
			} finally {
				connection.setAutoCommit(true);
			}
		} catch (SQLException ex) {
			return 0;
		}
	}

	public boolean activateSubmittedEntry(long entryId, String managerUsername) {
		Long managerId = findUserIdByUsername(managerUsername);
		if (managerId == null) {
			return false;
		}

		String fetchEntrySql = """
			SELECT id,
			       destination,
			       departure_time,
			       expected_passenger_count,
			       budget_amount,
			       created_by_id,
			       title,
			       department,
			       source_trip_request_id
			FROM timetable_entry
			WHERE id = ?
			  AND status = 'SUBMITTED'
		""";

		String findExistingSql = "SELECT id FROM trip_request WHERE source_timetable_entry_id = ? LIMIT 1";
		String updateLinkedRequestSql = """
			UPDATE trip_request
			SET destination = ?,
			    departure_time = ?,
			    passenger_count = ?,
			    requesting_department = ?,
			    status = 'CONFIRMED',
			    trip_type = 'ACADEMIC',
			    planned_budget = ?,
			    source_timetable_entry_id = ?,
			    updated_at = NOW()
			WHERE id = ?
		""";
		String insertTripSql = """
			INSERT INTO trip_request
			(destination, departure_time, passenger_count, requesting_department, status, trip_type, requester_id, manager_note, planned_budget, source_timetable_entry_id, created_at, updated_at)
			VALUES (?, ?, ?, ?, 'CONFIRMED', 'ACADEMIC', ?, ?, ?, ?, NOW(), NOW())
		""";
		String updateEntrySql = """
			UPDATE timetable_entry
			SET status = 'ACTIVE',
			    updated_at = NOW()
			WHERE id = ?
		""";

		try (Connection connection = DbUtil.getConnection()) {
			connection.setAutoCommit(false);
			try {
				TimetableRow row;
				try (PreparedStatement fetch = connection.prepareStatement(fetchEntrySql)) {
					fetch.setLong(1, entryId);
					try (ResultSet rs = fetch.executeQuery()) {
						if (!rs.next()) {
							connection.rollback();
							return false;
						}
						row = new TimetableRow(
							rs.getLong("id"),
							rs.getString("destination"),
							rs.getTimestamp("departure_time"),
							rs.getInt("expected_passenger_count"),
							rs.getBigDecimal("budget_amount"),
							rs.getObject("created_by_id") == null ? null : rs.getLong("created_by_id"),
							rs.getString("title"),
							rs.getString("department"),
							rs.getObject("source_trip_request_id") == null ? null : rs.getLong("source_trip_request_id")
						);
					}
				}

				boolean exists;
				try (PreparedStatement findExisting = connection.prepareStatement(findExistingSql)) {
					findExisting.setLong(1, entryId);
					try (ResultSet rs = findExisting.executeQuery()) {
						exists = rs.next();
					}
				}

				if (!exists) {
					if (row.sourceTripRequestId != null) {
						try (PreparedStatement updateLinked = connection.prepareStatement(updateLinkedRequestSql)) {
							updateLinked.setString(1, row.destination);
							updateLinked.setTimestamp(2, row.departureTime);
							updateLinked.setInt(3, Math.max(0, row.expectedPassengerCount));
							updateLinked.setString(4, row.department);
							updateLinked.setBigDecimal(5, sanitizeBudget(row.budgetAmount));
							updateLinked.setLong(6, entryId);
							updateLinked.setLong(7, row.sourceTripRequestId);
							int changed = updateLinked.executeUpdate();
							if (changed == 0) {
								connection.rollback();
								return false;
							}
						}
					} else {
						String note = "Timetabling source of truth: " + nullSafe(row.title) + " | Dept: " + nullSafe(row.department);
						try (PreparedStatement insert = connection.prepareStatement(insertTripSql)) {
							insert.setString(1, row.destination);
							insert.setTimestamp(2, row.departureTime);
							insert.setInt(3, Math.max(0, row.expectedPassengerCount));
							insert.setString(4, row.department);
							if (row.createdById == null) {
								insert.setNull(5, java.sql.Types.BIGINT);
							} else {
								insert.setLong(5, row.createdById);
							}
							insert.setString(6, note);
							insert.setBigDecimal(7, sanitizeBudget(row.budgetAmount));
							insert.setLong(8, entryId);
							insert.executeUpdate();
						}
					}
				}

				try (PreparedStatement updateEntry = connection.prepareStatement(updateEntrySql)) {
					updateEntry.setLong(1, entryId);
					updateEntry.executeUpdate();
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

	private TimetableEntry mapEntry(ResultSet rs) throws SQLException {
		TimetableEntry entry = new TimetableEntry();
		entry.setId(rs.getLong("id"));
		entry.setTitle(rs.getString("title"));
		entry.setDepartment(rs.getString("department"));
		entry.setDestination(rs.getString("destination"));

		Timestamp departureTime = rs.getTimestamp("departure_time");
		entry.setDepartureTime(departureTime == null ? null : departureTime.toLocalDateTime());
		entry.setExpectedPassengerCount(rs.getInt("expected_passenger_count"));
		entry.setBudgetAmount(sanitizeBudget(rs.getBigDecimal("budget_amount")));
		entry.setStatus(rs.getString("status"));
		entry.setCreatedByName(rs.getString("created_by_name"));
		Timestamp submittedAt = rs.getTimestamp("submitted_at");
		entry.setSubmittedAt(submittedAt == null ? null : submittedAt.toLocalDateTime());
		Object source = rs.getObject("source_trip_request_id");
		entry.setSourceTripRequestId(source == null ? null : rs.getLong("source_trip_request_id"));
		return entry;
	}

	private BigDecimal sanitizeBudget(BigDecimal value) {
		if (value == null || value.signum() < 0) {
			return BigDecimal.ZERO;
		}
		return value;
	}

	private String nullSafe(String value) {
		return value == null ? "-" : value;
	}

	private Long findUserIdByUsername(String username) {
		if (username == null || username.isBlank()) {
			return null;
		}

		String sql = "SELECT id FROM users WHERE username = ? LIMIT 1";
		try (Connection connection = DbUtil.getConnection();
			 PreparedStatement statement = connection.prepareStatement(sql)) {
			statement.setString(1, username.trim().toLowerCase());
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

	private record TimetableRow(long id,
	                            String destination,
	                            Timestamp departureTime,
	                            int expectedPassengerCount,
	                            BigDecimal budgetAmount,
	                            Long createdById,
	                            String title,
	                            String department,
	                            Long sourceTripRequestId) {
	}
}
