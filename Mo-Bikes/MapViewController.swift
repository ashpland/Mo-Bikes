//
//  MapViewController.swift
//  Mo-Bikes
//
//  Created by Andrew on 2018-02-15.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import UIKit
import MapKit
import RxCocoa

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var bikesDocksControl: UISegmentedControl!
    
    let locationManager: CLLocationManager = CLLocationManager()
    let mapDelegate = MapDelgate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLocation()
        
        self.mapView.delegate = self.mapDelegate
        
        MapViewModel.sharedInstance.mapView = self.mapView
        MapViewModel.sharedInstance.mapViewController = self
        
        
        NetworkManager.sharedInstance.updateStationData { (stations) in
            StationManager.sharedInstance.stations = stations.dictionary()
            MapViewModel.sharedInstance.display(stations)
        }
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
//        self.mapView.region = MKCoordinateRegionMake(currentLocation.coordinate,
//                                                     MKCoordinateSpanMake(0.007, 0.007))
        
        self.mapView.setRegion(MKCoordinateRegionMake(currentLocation.coordinate,
                                                      MKCoordinateSpanMake(0.007, 0.007)),
                               animated: true)
    }
    
    @IBAction func compassButtonPressed(_ sender: Any) {
        self.zoomToCurrent()
    }
    
}

