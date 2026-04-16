package com.transportmanager.dao;

import com.transportmanager.model.Driver;
import com.transportmanager.util.DbUtil;
import com.transportmanager.util.ValidationUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class DriverDAO {

	public List<Driver> findAllDrivers() {
		String sql = """
			SELECT id, full_name, license_number, status
			FROM users
			WHERE role = 'DRIVER'
			ORDER BY full_name ASC, id ASC
		""";
		List<Driver> drivers = new ArrayList<>();
		try (Connection connection = DbUtil.getConnection();
			 PreparedStatement statement = connection.prepareStatement(sql);
			 ResultSet rs = statement.executeQuery()) {
			while (rs.next()) {
				Driver driver = new Driver();
				driver.setId(rs.getLong("id"));
				driver.setFullName(rs.getString("full_name"));
				driver.setLicenseNumber(rs.getString("license_number"));
				driver.setStatus(rs.getString("status"));
				drivers.add(driver);
			}
			return drivers;
		} catch (SQLException ex) {
			return Collections.emptyList();
		}
	}

	public boolean createApprovedDriver(String fullName, String email, String username, String licenseNumber, String rawPassword) {
		if (fullName == null || email == null || username == null || licenseNumber == null || rawPassword == null) {
			return false;
		}
		if (!ValidationUtil.isAlphabeticWithSpaces(fullName) || !ValidationUtil.isAlphabetic(username)) {
			return false;
		}
		String sql = """
			INSERT INTO users
			(full_name, email, username, password_hash, role, license_number, status, is_active, created_at)
			VALUES (?, ?, ?, crypt(?, gen_salt('bf', 12)), 'DRIVER', ?, 'AVAILABLE', TRUE, NOW())
		""";
		try (Connection connection = DbUtil.getConnection();
			 PreparedStatement statement = connection.prepareStatement(sql)) {
			statement.setString(1, fullName);
			statement.setString(2, email);
			statement.setString(3, username);
			statement.setString(4, rawPassword);
			statement.setString(5, licenseNumber);
			return statement.executeUpdate() > 0;
		} catch (SQLException ex) {
			return false;
		}
	}

	public List<Driver> findAvailableDriversForTrip(long tripId) {
		String sql = """
			SELECT u.id, u.full_name, u.license_number
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
					driver.setLicenseNumber(rs.getString("license_number"));
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
