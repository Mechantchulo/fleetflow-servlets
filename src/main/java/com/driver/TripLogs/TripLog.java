package com.driver.TripLogs;

// looks the same as fuel log but with different variable names, trip specific, you get the jist of it. from Murach each distinct object has its own class
public class TripLog {
    private int startMileage;
    private int endMileage;
    private int distance;
    private double fuelUsed;
    private String timestamp;
    private String comments;

    public TripLog() {
    }

    public TripLog(int startMileage, int endMileage, double fuelUsed, String timestamp, String comments) {
        this.startMileage = startMileage;
        this.endMileage = endMileage;
        this.distance = endMileage - startMileage;
        this.fuelUsed = fuelUsed;
        this.timestamp = timestamp;
        this.comments = comments;
    }

    // Getters
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

    public String getTimestamp() {
        return timestamp;
    }

    public String getComments() {
        return comments;
    }

    public void setStartMileage(int startMileage) {
        this.startMileage = startMileage;
        recalculateDistance();
    }

    public void setEndMileage(int endMileage) {
        this.endMileage = endMileage;
        recalculateDistance();
    }

    public void setDistance(int distance) {
        this.distance = distance;
    }

    public void setFuelUsed(double fuelUsed) {
        this.fuelUsed = fuelUsed;
    }

    public void setTimestamp(String timestamp) {
        this.timestamp = timestamp;
    }

    public void setComments(String comments) {
        this.comments = comments;
    }

    private void recalculateDistance() {
        this.distance = this.endMileage - this.startMileage;
    }
}
