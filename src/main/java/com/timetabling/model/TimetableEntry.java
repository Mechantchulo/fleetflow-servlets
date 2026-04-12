package com.timetabling.model;

import java.time.LocalDateTime;
import java.math.BigDecimal;

public class TimetableEntry {

	private long id;
	private String title;
	private String department;
	private String destination;
	private LocalDateTime departureTime;
	private int expectedPassengerCount;
	private BigDecimal budgetAmount;
	private String status;
	private String createdByName;
	private LocalDateTime submittedAt;
	private Long sourceTripRequestId;

	public TimetableEntry() {
	}

	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getDepartment() {
		return department;
	}

	public void setDepartment(String department) {
		this.department = department;
	}

	public String getDestination() {
		return destination;
	}

	public void setDestination(String destination) {
		this.destination = destination;
	}

	public LocalDateTime getDepartureTime() {
		return departureTime;
	}

	public void setDepartureTime(LocalDateTime departureTime) {
		this.departureTime = departureTime;
	}

	public int getExpectedPassengerCount() {
		return expectedPassengerCount;
	}

	public void setExpectedPassengerCount(int expectedPassengerCount) {
		this.expectedPassengerCount = expectedPassengerCount;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public BigDecimal getBudgetAmount() {
		return budgetAmount;
	}

	public void setBudgetAmount(BigDecimal budgetAmount) {
		this.budgetAmount = budgetAmount;
	}

	public String getCreatedByName() {
		return createdByName;
	}

	public void setCreatedByName(String createdByName) {
		this.createdByName = createdByName;
	}

	public LocalDateTime getSubmittedAt() {
		return submittedAt;
	}

	public void setSubmittedAt(LocalDateTime submittedAt) {
		this.submittedAt = submittedAt;
	}

	public Long getSourceTripRequestId() {
		return sourceTripRequestId;
	}

	public void setSourceTripRequestId(Long sourceTripRequestId) {
		this.sourceTripRequestId = sourceTripRequestId;
	}
}
