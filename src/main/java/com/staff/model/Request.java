package com.staff.model;

public class Request {
    private int id;
    private String driver;
    private String driverInitials;
    private String destination;
    private String date;
    private String status;

    // Constructor
    public Request(int id, String driver, String driverInitials, String destination, String date, String status) {
        this.id = id;
        this.driver = driver;
        this.driverInitials = driverInitials;
        this.destination = destination;
        this.date = date;
        this.status = status;
    }

    // Getters & Setters
    public int getId() { return id; }
    public String getDriver() { return driver; }
    public String getDriverInitials() { return driverInitials; }
    public String getDestination() { return destination; }
    public String getDate() { return date; }
    public String getStatus() { return status; }

    public void setId(int id) { this.id = id; }
    public void setDriver(String driver) { this.driver = driver; }
    public void setDriverInitials(String initials) { this.driverInitials = initials; }
    public void setDestination(String destination) { this.destination = destination; }
    public void setDate(String date) { this.date = date; }
    public void setStatus(String status) { this.status = status; }
}