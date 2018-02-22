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
    let mapDelegate: MKMapViewDelegate = MapDelgate()
    var mapViewModel: MapViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLocation()
        
        self.mapView.delegate = self.mapDelegate
        
        mapViewModel = MapViewModel(for: self, with: StationManager.sharedInstance)
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

        let currentRegion = MKCoordinateRegionMake(currentLocation.coordinate,
                                                   MKCoordinateSpanMake(0.007, 0.007))
        
        self.mapView.setRegion(currentRegion ,animated: true)
    }
    
    @IBAction func compassButtonPressed(_ sender: Any) {
        self.zoomToCurrent()
    }
    
    @IBAction func refreshPressed(_ sender: Any) {
        NetworkManager.sharedInstance.updateStationData { (stations) in
            StationManager.sharedInstance.update(stations)
        }
    }
    
}

