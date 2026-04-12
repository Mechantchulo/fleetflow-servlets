package com.driver.driverdashboard;

//This is the model class to meet the MVC, helps avoid arraylist of trips in the servlet and instead have a list of trip objects
//In class was told this a
public class Trip {
    private String id;
    private String destination;
    private String date;
    private int passengers;

    public Trip() {
    }

    public Trip(String id, String destination, String date, int passengers) {
        this.id = id;
        this.destination = destination;
        this.date = date;
        this.passengers = passengers;
    }

    public String getId() {
        return id;
    }

    public String getDestination() {
        return destination;
    }

    public String getDate() {
        return date;
    }

    public int getPassengers() {
        return passengers;
    }

    public void setId(String id) {
        this.id = id;
    }

    public void setDestination(String destination) {
        this.destination = destination;
    }

    public void setDate(String date) {
        this.date = date;
    }

    public void setPassengers(int passengers) {
        this.passengers = passengers;
    }
}
