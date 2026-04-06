package com.staff.model;

public class Trip {
    private int id;
    private String date;
    private String driver;
    private String driverInitials;
    private String route;
    private String duration;
    private String status;

    public Trip(int id, String date, String driver, String driverInitials,
                String route, String duration, String status) {
        this.id = id;
        this.date = date;
        this.driver = driver;
        this.driverInitials = driverInitials;
        this.route = route;
        this.duration = duration;
        this.status = status;
    }

    public int getId() { return id; }
    public String getDate() { return date; }
    public String getDriver() { return driver; }
    public String getDriverInitials() { return driverInitials; }
    public String getRoute() { return route; }
    public String getDuration() { return duration; }
    public String getStatus() { return status; }
}