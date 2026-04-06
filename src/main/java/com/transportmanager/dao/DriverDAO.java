package com.transportmanager.dao;

import com.transportmanager.model.Driver;
import com.transportmanager.util.DbUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class DriverDAO {

	public List<Driver> findAvailableDriversForTrip(long tripId) {
		String sql = """
			SELECT u.id, u.full_name
			FROM users u
			WHERE u.role = 'DRIVER'
			  AND NOT EXISTS (
			      SELECT 1
			      FROM trip_assignment ta
			      WHERE ta.driver_id = u.id
			        AND ta.status = 'ASSIGNED'
			  )
			ORDER BY u.full_name
		""";

		List<Driver> drivers = new ArrayList<>();
		try (Connection connection = DbUtil.getConnection();
			 PreparedStatement statement = connection.prepareStatement(sql)) {
			try (ResultSet rs = statement.executeQuery()) {
				while (rs.next()) {
					Driver driver = new Driver();
					driver.setId(rs.getLong("id"));
					driver.setFullName(rs.getString("full_name"));
					driver.setStatus("AVAILABLE");
					drivers.add(driver);
				}
			}
			return drivers;
		} catch (SQLException ex) {
			return Collections.emptyList();
		}
	}

	public boolean isDriverAvailable(long driverId) {
		String sql = """
			SELECT 1
			FROM users u
			WHERE u.id = ?
			  AND u.role = 'DRIVER'
			  AND NOT EXISTS (
			      SELECT 1
			      FROM trip_assignment ta
			      WHERE ta.driver_id = u.id
			        AND ta.status = 'ASSIGNED'
			  )
		""";
		try (Connection connection = DbUtil.getConnection();
			 PreparedStatement statement = connection.prepareStatement(sql)) {
			statement.setLong(1, driverId);
			try (ResultSet rs = statement.executeQuery()) {
				return rs.next();
			}
		} catch (SQLException ex) {
			return false;
		}
	}
}

