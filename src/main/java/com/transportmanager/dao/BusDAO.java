package com.transportmanager.dao;

import com.transportmanager.model.Bus;
import com.transportmanager.util.DbUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class BusDAO {

	public List<Bus> findAvailableBusesByCapacity(int requiredCapacity) {
		List<Bus> buses = new ArrayList<>();
		String sql = "SELECT id, plate_number, mileage, status FROM vehicle WHERE status = 'AVAILABLE' ORDER BY id";

		try (Connection connection = DbUtil.getConnection();
			 Statement statement = connection.createStatement();
			 ResultSet rs = statement.executeQuery(sql)) {
			while (rs.next()) {
				Bus bus = new Bus();
				bus.setId(rs.getLong("id"));
				bus.setPlateNumber(rs.getString("plate_number"));
				bus.setMileage((long) rs.getDouble("mileage"));
				bus.setStatus(rs.getString("status"));
				bus.setCapacity(requiredCapacity);
				buses.add(bus);
			}
			return buses;
		} catch (SQLException ex) {
			return Collections.emptyList();
		}
	}

	public boolean isBusAvailable(long busId) {
		String sql = "SELECT status FROM vehicle WHERE id = ?";
		try (Connection connection = DbUtil.getConnection();
			 PreparedStatement statement = connection.prepareStatement(sql)) {
			statement.setLong(1, busId);
			try (ResultSet rs = statement.executeQuery()) {
				if (!rs.next()) {
					return false;
				}
				return "AVAILABLE".equalsIgnoreCase(rs.getString("status"));
			}
		} catch (SQLException ex) {
			return false;
		}
	}
}

