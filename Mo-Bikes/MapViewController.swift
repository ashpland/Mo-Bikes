//
//  MapViewController.swift
//  Mo-Bikes
//
//  Created by Andrew on 2018-02-15.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var bikesDocksControl: UISegmentedControl!
    
    let locationManager: CLLocationManager = CLLocationManager()
    let mapDelegate: MKMapViewDelegate = MapDelgate()
    var mapViewModel: MapViewModel!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLocation()
        
        self.mapView.delegate = self.mapDelegate
        
        mapViewModel = MapViewModel(StationManager.sharedInstance)
        
        setupRx()
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
    
    func setupRx() {
        bikesDocksControl.rx.selectedSegmentIndex
            .map { return $0 == 0 ? .bikes : .docks }
            .bind(to: mapViewModel.bikesOrDocks)
            .disposed(by: disposeBag)
        
        mapViewModel.stationAnnotations
            .subscribe(onNext: { self.mapView.addAnnotations($0) } )
            .disposed(by: disposeBag)
        
        mapViewModel.removeAnnotations
            .subscribe(onNext: { self.mapView.removeAnnotation($0) } )
            .disposed(by: disposeBag)
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

