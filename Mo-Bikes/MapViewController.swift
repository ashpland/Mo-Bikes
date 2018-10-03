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
    
    let locationManager = CLLocationManager()
    let viewModel = MapViewModel()
    let disposeBag = DisposeBag()
    
    let networker = Networker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        networker.temp()
        
//        self.setupLocation()
//        mapView.delegate = self
//        setupRx()
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
        
        let currentRegion = MKCoordinateRegion(center: currentLocation.coordinate,
                                               span: MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007))
        
        self.mapView.setRegion(currentRegion ,animated: true)
    }
    
    func setupRx() {
        bikesDocksControl.rx.selectedSegmentIndex.asDriver()
            .map { return $0 == 0 ? .bikes : .docks }
            .drive(viewModel.bikesOrDocks)
            .disposed(by: disposeBag)
        
        viewModel.stationsDriver
            .drive(onNext: { self.mapView.addAnnotations($0) })
            .disposed(by: disposeBag)
        
        viewModel.stationsToRemoveSignal
            .emit(onNext: { self.mapView.removeAnnotation($0) })
            .disposed(by: disposeBag)
    }
    
    @IBAction func compassButtonPressed(_ sender: Any) {
        self.zoomToCurrent()
    }
    
    @IBAction func refreshPressed(_ sender: Any) {
        viewModel.updateStations()
    }
    
}


extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let station = annotation as? Station {
            let stationView = StationView()
            stationView.viewModel = StationViewModel(station: station,
                                                     bikesOrDocksState: viewModel.bikesOrDocks.asDriver())
            return stationView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let stationView = view as? StationView {
            stationView.viewModel.stationIsSelected.accept(true)
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if let stationView = view as? StationView {
            stationView.viewModel.stationIsSelected.accept(false)
        }
    }
}

