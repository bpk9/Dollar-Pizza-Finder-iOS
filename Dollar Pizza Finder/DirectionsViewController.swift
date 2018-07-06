//
//  DirectionsViewController.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 6/26/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//
import UIKit
import CoreLocation
import GoogleMaps

class DirectionsViewController: UIViewController, CLLocationManagerDelegate {
    
    // View Components
    @IBOutlet var map: GMSMapView!
    @IBOutlet var directionsLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var directionsPic: UIImageView!
    @IBOutlet var backBtn: UIButton!
    @IBOutlet var nextBtn: UIButton!
    
    // manages current location services
    let manager = CLLocationManager()
    var currentLocation: CLLocation!
    
    // manages google directions
    var directions: GoogleDirections!
    
    // origin information
    var origin: CLLocationCoordinate2D!
    
    // destination information
    var destination: GMSMarker!
    var data: Place!
    
    // step counter
    var step: Int!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // get destination data
        self.data = destination.userData as! Place
        
        // add title to view controller
        self.title = "Directions to " + self.data.name
        
        // set up location services
        self.manager.delegate = self
        self.manager.desiredAccuracy = kCLLocationAccuracyBest // get most accurate location
        self.manager.requestWhenInUseAuthorization() // get permission
        self.manager.startUpdatingLocation()  // update current location
        
        // initialize counter
        self.step = -1
        
        // set up google directions
        self.directions = GoogleDirections(origin: self.origin, destination: self.data.place_id, mode: "transit")
        
        
        // add destination pin to map
        let marker = GMSMarker()
        let location = self.data.geometry.location
        marker.position = CLLocationCoordinate2DMake(location.lat, location.lng)
        marker.title = self.data.name
        marker.map = self.map
        self.map.selectedMarker = marker
        
        
        // add directions to map
        self.directions.addPolyline(map: self.map)
        
        self.setOverview()
        
        
    }
    
    // called after current location is updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        // set origin
        self.origin = locations.first?.coordinate
        
        // enable location for google map
        self.map.isMyLocationEnabled = true
        
        // stop updating location
        self.manager.stopUpdatingLocation()
        
    }
    
    // when start/next button is tapped
    @IBAction func nextAction(_ sender: Any) {
        
        // increment step
        self.step = self.step + 1
        
        // if overview is showing then set up buttons for directions
        if self.backBtn.isHidden {
            self.backBtn.isHidden = false
        }
        
        if self.nextBtn.currentTitle == "Start" {
            self.nextBtn.setTitle("Next", for: .normal)
            self.nextBtn.backgroundColor = .green
        }
        
        // update information
        self.setDirections(num: self.step)
        
    }
    
    // when back button is tapped
    @IBAction func backAction(_ sender: Any) {
        
        // decrement step
        self.step = self.step - 1
        
        // if next button is hidden then show it again
        if self.nextBtn.isHidden || self.nextBtn.currentTitle == "Start" {
            self.nextBtn.isHidden = false
            self.nextBtn.setTitle("Next", for: .normal)
            self.nextBtn.backgroundColor = .green
        }
        
        // if on initial step, revert to overview
        if self.step >= 0 {
            self.setDirections(num: self.step)
        } else {
            self.step = -1
            self.setOverview()
        }
        
        
    }
    
    // set info for overview
    func setOverview() {
        
        self.backBtn.isHidden = true
        self.nextBtn.backgroundColor = .blue
        self.nextBtn.setTitle("Start", for: .normal)
        
        self.directionsPic.image = UIImage(named: "Launch.png")
        
        self.directions.getDirections() { (route) -> () in
                
            self.directions.updateCamera(map: self.map, route: route)
                
            self.directionsLabel.text = "Route to " + self.data.name
            self.distanceLabel.text = route.legs.first?.distance.text
            self.durationLabel.text = route.legs.first?.duration.text
                
        }
    
    }
    
    // set directions info for given step
    func setDirections(num: Int) {
        self.directions.getSteps() { (steps) -> () in
                
            // get current step
            let step = steps[num]
                
            // zoom map to step
            let start = CLLocationCoordinate2DMake(step.start_location.lat, step.start_location.lng)
            let end = CLLocationCoordinate2DMake(step.end_location.lat, step.end_location.lng)
            self.map.moveCamera(GMSCameraUpdate.fit(GMSCoordinateBounds(coordinate: start, coordinate: end)))
                
            // update duration
            self.durationLabel.text = step.duration.text
                
            // if travel mode is transit show num of stops
            if step.travel_mode == "TRANSIT" {
                self.distanceLabel.text = String(step.transit_details!.num_stops) + " stops"
                    
                // try to set image for train line
                if let line = step.transit_details?.line.icon {
                    self.setDirectionsPic(path: line)
                } else if let icon = step.transit_details?.line.vehicle.icon {
                    self.setDirectionsPic(path: icon)
                } else {
                    self.directionsPic.image = UIImage(named: "train-logo.png")
                }
                    
            } else {
                self.distanceLabel.text = step.distance.text
                self.directionsPic.image = UIImage(named: "walking.png")
            }
                
            // update directions label and hide the next button on last step
            if self.step == (steps.count - 1) {
                self.directionsLabel.text = "Walk to " + self.data.name
                self.nextBtn.isHidden = true
            } else {
                self.directionsLabel.text = step.html_instructions
            }
                
        }
    }
    
    func setDirectionsPic(path: String) {
        let url = URL(string: "https:" + path)
        let data = try? Data(contentsOf: url!)
        self.directionsPic.image = UIImage(data: data!)
    }
    
}
