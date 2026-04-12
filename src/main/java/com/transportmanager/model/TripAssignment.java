package com.transportmanager.model;

import java.time.LocalDateTime;

public class TripAssignment {

	private long id;
	private long tripId;
	private long busId;
	private long driverId;
	private long assignedById;
	private String assignedByName;
	private LocalDateTime assignedAt;
	private String status;
	private boolean overrideUsed;
	private String overrideReason;

	public TripAssignment() {
	}

	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public long getTripId() {
		return tripId;
	}

	public void setTripId(long tripId) {
		this.tripId = tripId;
	}

	public long getBusId() {
		return busId;
	}

	public void setBusId(long busId) {
		this.busId = busId;
	}

	public long getDriverId() {
		return driverId;
	}

	public void setDriverId(long driverId) {
		this.driverId = driverId;
	}

	public long getAssignedById() {
		return assignedById;
	}

	public void setAssignedById(long assignedById) {
		this.assignedById = assignedById;
	}

	public String getAssignedByName() {
		return assignedByName;
	}

	public void setAssignedByName(String assignedByName) {
		this.assignedByName = assignedByName;
	}

	public LocalDateTime getAssignedAt() {
		return assignedAt;
	}

	public void setAssignedAt(LocalDateTime assignedAt) {
		this.assignedAt = assignedAt;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public boolean isOverrideUsed() {
		return overrideUsed;
	}

	public void setOverrideUsed(boolean overrideUsed) {
		this.overrideUsed = overrideUsed;
	}

	public String getOverrideReason() {
		return overrideReason;
	}

	public void setOverrideReason(String overrideReason) {
		this.overrideReason = overrideReason;
	}
}
