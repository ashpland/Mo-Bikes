//
//  MapViewController.swift
//  Mo-Bikes
//
//  Created by Andrew on 2018-02-15.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    let locationManager: CLLocationManager = CLLocationManager()
    let mapDelegate = MapDelgate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLocation()
        
        self.mapView.delegate = self.mapDelegate
        
        MapViewModel.sharedInstance.mapView = self.mapView
        let _ = StationManager.sharedInstance
        
        
        
    }

    func setupLocation() {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
        self.mapView.showsPointsOfInterest = false
        self.zoomToCurrent()
    }
    
    func zoomToCurrent() {
        guard let currentLocation = self.locationManager.location else {
            print("Can't get current location")
            return
        }
        self.mapView.region = MKCoordinateRegionMake(currentLocation.coordinate,
                                                     MKCoordinateSpanMake(0.007, 0.007))
    }
}

