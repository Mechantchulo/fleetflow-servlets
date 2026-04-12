package com.auth;

import com.transportmanager.util.DbUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Locale;

public class AuthDAO {

	public AuthUser authenticate(String username, String rawPassword) {
		boolean debug = Boolean.parseBoolean(System.getProperty("AUTH_DEBUG", "false"));
		String sql = """
			SELECT id, username, full_name, role
			FROM users
			WHERE username = ?
			  AND is_active = TRUE
			  AND password_hash IS NOT NULL
			  AND password_hash = crypt(?, password_hash)
			LIMIT 1
		""";

		try (Connection connection = DbUtil.getConnection();
			 PreparedStatement statement = connection.prepareStatement(sql)) {
			if (debug) {
				System.out.println("[AUTH_DEBUG] Attempt login for username=" + username);
			}
			statement.setString(1, username);
			statement.setString(2, rawPassword);
			try (ResultSet rs = statement.executeQuery()) {
				if (!rs.next()) {
					if (debug) {
						System.out.println("[AUTH_DEBUG] Login failed for username=" + username);
					}
					return null;
				}

				AuthUser user = new AuthUser();
				user.setId(rs.getLong("id"));
				user.setUsername(rs.getString("username"));
				user.setFullName(rs.getString("full_name"));
				user.setRole(rs.getString("role"));
				if (debug) {
					System.out.println("[AUTH_DEBUG] Login ok for username=" + username + " role=" + user.getRole());
				}
				return user;
			}
		} catch (SQLException ex) {
			if (debug) {
				System.out.println("[AUTH_DEBUG] Login error for username=" + username + " error=" + ex.getMessage());
			}
			return null;
		}
	}

	public void markSuccessfulLogin(long userId) {
		String sql = "UPDATE users SET last_login_at = NOW() WHERE id = ?";
		try (Connection connection = DbUtil.getConnection();
			 PreparedStatement statement = connection.prepareStatement(sql)) {
			statement.setLong(1, userId);
			statement.executeUpdate();
		} catch (SQLException ex) {
			// Intentionally ignore: login should not fail because audit timestamp failed.
		}
	}

	public boolean registerStaff(String fullName,
	                             String department,
	                             String email,
	                             String username,
	                             String rawPassword) {
		if (isBlank(fullName) || isBlank(department) || isBlank(email) || isBlank(username) || isBlank(rawPassword)) {
			return false;
		}

		String normalizedUsername = username.trim().toLowerCase(Locale.ROOT);
		String normalizedEmail = email.trim().toLowerCase(Locale.ROOT);

		String sql = """
			INSERT INTO users
			(full_name, email, username, password_hash, role, status, is_active, department, created_at)
			VALUES (?, ?, ?, crypt(?, gen_salt('bf', 12)), 'STAFF', 'AVAILABLE', TRUE, ?, NOW())
		""";

		try (Connection connection = DbUtil.getConnection();
			 PreparedStatement statement = connection.prepareStatement(sql)) {
			statement.setString(1, fullName.trim());
			statement.setString(2, normalizedEmail);
			statement.setString(3, normalizedUsername);
			statement.setString(4, rawPassword);
			statement.setString(5, department.trim());
			return statement.executeUpdate() > 0;
		} catch (SQLException ex) {
			return false;
		}
	}

	public String findStaffDepartment(String username) {
		if (isBlank(username)) {
			return null;
		}
		String sql = "SELECT department FROM users WHERE username = ? AND role = 'STAFF' LIMIT 1";
		try (Connection connection = DbUtil.getConnection();
			 PreparedStatement statement = connection.prepareStatement(sql)) {
			statement.setString(1, username.trim().toLowerCase(Locale.ROOT));
			try (ResultSet rs = statement.executeQuery()) {
				if (rs.next()) {
					return rs.getString("department");
				}
			}
		} catch (SQLException ex) {
			return null;
		}
		return null;
	}

	private boolean isBlank(String value) {
		return value == null || value.trim().isEmpty();
	}
}
