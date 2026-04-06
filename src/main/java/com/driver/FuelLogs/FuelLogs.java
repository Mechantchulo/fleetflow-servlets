package com.driver.FuelLogs;

public class FuelLogs {
    private String date;
    private int startMileage;
    private int endMileage;
    private int distance;
    private double fuelUsed;
    private String comments;

    public FuelLogs(String date, int startMileage, int endMileage, double fuelUsed, String comments) {
        this.date = date;
        this.startMileage = startMileage;
        this.endMileage = endMileage;
        this.distance = endMileage - startMileage; // auto-calculate
        this.fuelUsed = fuelUsed;
        this.comments = comments;
    }

    // Getters
    public String getDate() {
        return date;
    }

    public int getStartMileage() {
        return startMileage;
    }

    public int getEndMileage() {
        return endMileage;
    }

    public int getDistance() {
        return distance;
    }

    public double getFuelUsed() {
        return fuelUsed;
    }

    public String getComments() {
        return comments;
    }
}