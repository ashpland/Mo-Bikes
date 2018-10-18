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
    @IBOutlet weak var trayView: UIView!
    @IBOutlet weak var trayStackView: UIStackView!
    @IBOutlet weak var trayBottomView: UIStackView!
    @IBOutlet weak var trayViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var hamburgerButton: MoButtonHamburger!
    
    private var bottomOffset: CGFloat {
        return (trayStackView.spacing + trayBottomView.frame.height + 20) * -1
    }
    
    var bikesOrDocksState: BikesOrDocks = .bikes {
        didSet {
            mapView |> refreshStationViews(with: bikesOrDocksState)
        }
    }
    
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        setupView()
        startUpdatingStations()
    }
    
    private func setupMap() {
        mapView.delegate = self
        locationManager |> setup
        mapView |> setup >>> zoomToCurrent(locationManager)
    }
    
    private func setupView() {
        trayViewBottomConstraint.constant = bottomOffset
        trayBottomView.alpha = 0.0
        trayView.layer.cornerRadius = 20
    }
    
    private func startUpdatingStations() {
        updateStations()
        
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.updateStations()
        }
    }
    
    private func updateStations() {
        getStationData(
            decodeStationData
                >>> update(existingStations: mapView |> getStations)
                >>> update(mapView: mapView)
                >>> refreshStationViews(with: .bikes))
    }
    
    @IBAction func topViewTapped(_ sender: UITapGestureRecognizer) {
        hamburgerButton |> openBottomDrawer
    }
    
    @IBAction func buttonPressed(_ sender: MoButton) {
        switch sender.type {
        case .bikes:
            bikesOrDocksState = .bikes
        case .docks:
            bikesOrDocksState = .docks
        case .fountains, .washrooms:
            sender as? MoButtonToggle |> displaySupplementAnnotations(in: mapView)
        case .contact:
            callMobi()
        case .compass:
            mapView |> zoomToCurrent(locationManager)
        case .hamburger:
            sender as? MoButtonToggle |> openBottomDrawer
        default:
            return
        }
    }
    
    private func openBottomDrawer(_ toggle: MoButtonToggle?) {
        guard let toggle = toggle else { return }
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5) {
            self.trayViewBottomConstraint.constant = toggle.isOn ? self.bottomOffset : 0
            self.trayBottomView.alpha = toggle.isOn ? 0.0 : 1.0
            self.view.layoutIfNeeded()
        }
        toggle.isOn.toggle()
    }
}

func setup(locationManager: CLLocationManager) {
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
}

func setup(mapView: MKMapView) -> MKMapView {
    mapView.register(StationView.self, forAnnotationViewWithReuseIdentifier: "\(StationView.self)")
    mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "\(SupplementPointType.self)")
    do {
        mapView.addOverlays(try loadBikeways(), level: .aboveRoads)
    }
    catch {
        debugPrint(error.localizedDescription)
    }
    return mapView
}

func zoomToCurrent(_ locationManager: CLLocationManager) -> (MKMapView) -> Void {
    return { mapView in
        guard let currentLocation = locationManager.location else {
            debugPrint("Can't get current location")
            return
        }
        
        let currentRegion = MKCoordinateRegion(center: currentLocation.coordinate,
                                               span: MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007))
        
        mapView.setRegion(currentRegion, animated: true)
    }
}

func getStations(from mapView: MKMapView) -> [Station] {
    return mapView.annotations.compactMap { $0 as? Station }
}

func update(mapView: MKMapView) -> ((current: [Station], remove: [Station])) -> MKMapView {
    return { updates in
        mapView.addAnnotations(updates.current)
        mapView.removeAnnotations(updates.remove)
        return mapView
    }
}

func refreshStationViews(with bikesOrDocks: BikesOrDocks) -> (MKMapView) -> Void {
    return { mapView in
        mapView.annotations
            |> compactMap { mapView.view(for: $0) as? StationView }
            >>> map(configureStationView(bikesOrDocks))
    }
}

func displaySupplementAnnotations(in mapView: MKMapView) -> (MoButtonToggle?) -> Void {
    return { toggle in
        guard let toggle = toggle else { return }
        
        let pointType: SupplementPointType
        switch toggle.type {
        case .washrooms:
            pointType = .washroom
        case .fountains:
            pointType = .fountain
        default:
            return
        }
        
        if toggle.isOn {
            toggle.tintColor = Styles.Color.inactive
            mapView.annotations
                |> compactMap(justAnnotations(of: pointType))
                >>> mapView.removeAnnotations
        } else {
            toggle.tintColor = Styles.Color.secondary
            do {
                try pointType
                    |> loadSupplementAnnotations
                    >>> mapView.addAnnotations
            }
            catch {
                debugPrint(error.localizedDescription)
                return
            }
            
        }
        
        toggle.isOn.toggle()
    }
}

func callMobi() {
    if let url = URL(string: "tel://7786551800") {
        UIApplication.shared.open(url)
    }
}
