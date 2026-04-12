package com.transportmanager.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public final class DbUtil {

	private static final String DEFAULT_HOST = "localhost";
	private static final String DEFAULT_PORT = "5434";
	private static final String DEFAULT_DB = "fleetflow";
	private static final String DEFAULT_USER = "postgres";
	private static final String DEFAULT_PASSWORD = "fleetflow2026";

	private DbUtil() {
	}

	public static Connection getConnection() throws SQLException {
		ensurePostgresDriverLoaded();

		String host = readValue("DB_HOST", DEFAULT_HOST);
		String port = readValue("DB_PORT", DEFAULT_PORT);
		String dbName = readValue("DB_NAME", DEFAULT_DB);
		String user = readValue("DB_USER", DEFAULT_USER);
		String password = readValue("DB_PASSWORD", DEFAULT_PASSWORD);

		String url = "jdbc:postgresql://" + host + ":" + port + "/" + dbName;
		return DriverManager.getConnection(url, user, password);
	}

	private static void ensurePostgresDriverLoaded() throws SQLException {
		try {
			Class.forName("org.postgresql.Driver");
		} catch (ClassNotFoundException ex) {
			throw new SQLException("PostgreSQL JDBC driver is missing from runtime classpath.", ex);
		}
	}

	private static String readValue(String key, String defaultValue) {
		String property = System.getProperty(key);
		if (property != null && !property.isBlank()) {
			return property;
		}

		String env = System.getenv(key);
		if (env != null && !env.isBlank()) {
			return env;
		}

		return defaultValue;
	}
}
