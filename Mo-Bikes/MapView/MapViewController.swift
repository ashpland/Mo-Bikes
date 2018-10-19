//
//  MapViewController.swift
//  Mo-Bikes
//
//  Created by Andrew on 2018-02-15.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import UIKit
import MapKit
import Alamofire

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
    
    var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        setupView()
        startUpdatingStations()
    }
    
    private func setupMap() {
        locationManager &|> setupLocationManager
        mapView &|> setupMapView(delegate: self) <> zoomTo(locationManager.location)
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
        getStationData { self.processNewStationData($0) }
    }
    
    private func processNewStationData(_ response: DataResponse<Data>) {
        do {
            try response |> decodeResponse
                >>> update(existingStations: mapView |> getStations)
                >>> update(mapView: &mapView)
                >>> refreshStationViews(with: .bikes)
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
    @IBAction func topViewTapped(_ sender: UITapGestureRecognizer) {
        hamburgerButton.isOn |> openBottomDrawer
        hamburgerButton.isOn.toggle()
    }
    
    @IBAction func buttonPressed(_ sender: MoButton) {
        do {
            switch sender.type {
            case .bikes:
                bikesOrDocksState = .bikes
            case .docks:
                bikesOrDocksState = .docks
            case .fountains:
                if var toggleButton = sender as? MoButtonToggle {
                    toggleButton &|> updateToggleButton
                    try mapView &|> displaySupplementAnnotations(.fountain, toggleButton.isOn)
                }
            case .washrooms:
                if var toggleButton = sender as? MoButtonToggle {
                    toggleButton &|> updateToggleButton
                    try mapView &|> displaySupplementAnnotations(.washroom, toggleButton.isOn)
                }
            case .contact:
                callMobi()
            case .compass:
                mapView &|> zoomTo(locationManager.location)
            case .hamburger:
                hamburgerButton.isOn |> openBottomDrawer
                hamburgerButton.isOn.toggle()
            default:
                return
            }
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
    private func openBottomDrawer(_ shouldOpen: Bool) {
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5) {
            self.trayViewBottomConstraint.constant = shouldOpen ? self.bottomOffset : 0
            self.trayBottomView.alpha = shouldOpen ? 0.0 : 1.0
            self.view.layoutIfNeeded()
        }
    }
    
}

func updateToggleButton(_ button: inout MoButtonToggle) {
    button.isOn.toggle()
    button.tintColor = button.isOn ? Styles.Color.secondary : Styles.Color.inactive
}

func displaySupplementAnnotations(_ pointType: SupplementPointType, _ turnOn: Bool) -> (inout MKMapView) throws -> Void {
    return { mapView in
        if turnOn {
            try pointType
                |> loadSupplementAnnotations
                >>> mapView.addAnnotations
        } else {
            mapView.annotations
                .compactMap(justAnnotations(of: pointType))
                |> mapView.removeAnnotations
        }
    }
}

func callMobi() {
    if let url = URL(string: "tel://7786551800") {
        UIApplication.shared.open(url)
    }
}
