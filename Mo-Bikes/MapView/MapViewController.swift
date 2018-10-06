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

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupLocation()
        setupRx()
    }

    func setupLocation() {
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        mapView.showsPointsOfInterest = false
        zoomToCurrent()
    }

    func zoomToCurrent() {
        guard let currentLocation = self.locationManager.location else {
            debugPrint("Can't get current location")
            return
        }

        let currentRegion = MKCoordinateRegion(center: currentLocation.coordinate,
                                               span: MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007))

        mapView.setRegion(currentRegion, animated: true)
    }

    func setupRx() {
        bikesDocksControl.rx.selectedSegmentIndex.asDriver()
            .map { return $0 == 0 ? .bikes : .docks }
            .drive(viewModel.bikesOrDocks)
            .disposed(by: disposeBag)

        viewModel.stationsToAddDriver
            .drive(mapView.rx.addAnnotations)
            .disposed(by: disposeBag)

        viewModel.stationsToRemoveSignal
            .emit(to: mapView.rx.removeAnnotation)
            .disposed(by: disposeBag)

        Signal<Int>
            .timer(0, period: 60)
            .emit(onNext: { [weak self] _ in
                self?.viewModel.updateStations()
            })
            .disposed(by: disposeBag)
    }

    @IBAction func compassButtonPressed(_ sender: Any) {
        zoomToCurrent()
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
