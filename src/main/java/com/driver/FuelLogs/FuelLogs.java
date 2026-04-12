package com.driver.FuelLogs;

//looks the same as trip log but with different variable names, fuel specific, could have made a parent class but wanted to keep it simple and straightforward for now
public class FuelLogs {
    private String date;
    private int startMileage;
    private int endMileage;
    private int distance;
    private double fuelUsed;
    private String comments;

    public FuelLogs() {
    }

    public FuelLogs(String date, int startMileage, int endMileage, double fuelUsed, String comments) {
        this.date = date;
        this.startMileage = startMileage;
        this.endMileage = endMileage;
        this.distance = endMileage - startMileage;
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

    public void setDate(String date) {
        this.date = date;
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

    public void setComments(String comments) {
        this.comments = comments;
    }

    private void recalculateDistance() {
        this.distance = this.endMileage - this.startMileage;
    }
}
