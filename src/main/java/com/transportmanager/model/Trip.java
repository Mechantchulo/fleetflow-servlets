package com.transportmanager.model;

import java.time.LocalDate;
import java.math.BigDecimal;

public class Trip {

	private long id;
	private String requesterName;
	private String destination;
	private String department;
	private LocalDate departureDate;
	private int passengerCount;
	private String priority;
	private String status;
	private String requestNote;
	private BigDecimal requestedBudget;
	private boolean hasSchedulingDocument;

	public Trip() {
	}

	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public String getRequesterName() {
		return requesterName;
	}

	public void setRequesterName(String requesterName) {
		this.requesterName = requesterName;
	}

	public String getDestination() {
		return destination;
	}

	public void setDestination(String destination) {
		this.destination = destination;
	}

	public String getDepartment() {
		return department;
	}

	public void setDepartment(String department) {
		this.department = department;
	}

	public LocalDate getDepartureDate() {
		return departureDate;
	}

	public void setDepartureDate(LocalDate departureDate) {
		this.departureDate = departureDate;
	}

	public int getPassengerCount() {
		return passengerCount;
	}

	public void setPassengerCount(int passengerCount) {
		this.passengerCount = passengerCount;
	}

	public String getPriority() {
		return priority;
	}

	public void setPriority(String priority) {
		this.priority = priority;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getRequestNote() {
		return requestNote;
	}

	public void setRequestNote(String requestNote) {
		this.requestNote = requestNote;
	}

	public BigDecimal getRequestedBudget() {
		return requestedBudget;
	}

	public void setRequestedBudget(BigDecimal requestedBudget) {
		this.requestedBudget = requestedBudget;
	}

	public boolean isHasSchedulingDocument() {
		return hasSchedulingDocument;
	}

	public void setHasSchedulingDocument(boolean hasSchedulingDocument) {
		this.hasSchedulingDocument = hasSchedulingDocument;
	}
}
