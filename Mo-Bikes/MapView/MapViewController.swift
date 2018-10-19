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
    @IBOutlet weak var washroomsButton: MoButtonWashrooms!
    @IBOutlet weak var fountainsButton: MoButtonFountains!

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
        doCatchPrint {
            try mapView &|> setupMapView(delegate: self) <> zoomTo(locationManager.location)
        }
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
        doCatchPrint {
            try response |> decodeResponse
                >>> update(existingStations: mapView |> getStations)
                >>> update(mapView: &mapView)
                >>> refreshStationViews(with: .bikes)
        }
    }

    @IBAction func topViewTapped(_ sender: UITapGestureRecognizer) {
        hamburgerButton.isOn |> openBottomDrawer
        hamburgerButton.isOn.toggle()
    }

    @IBAction func buttonPressed(_ sender: MoButton) {
            switch sender.type {
            case .bikes:
                bikesOrDocksState = .bikes
            case .docks:
                bikesOrDocksState = .docks
            case .fountains, .washrooms:
                handleSupplementAnnotations(for: sender)
            case .contact:
                callMobi()
            case .compass:
                doCatchPrint {
                    try self.mapView &|> zoomTo(locationManager.location)
                }
            case .hamburger:
                hamburgerButton.isOn |> openBottomDrawer
                hamburgerButton.isOn.toggle()
            default:
                return
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

    private func handleSupplementAnnotations(for sender: MoButton) {
        guard let toggleButton = sender as? MoButtonToggle else { return }
        doCatchPrint {
            switch (toggleButton.type, toggleButton.isOn) {
            case (.fountains, true):
                try fountainsOn(false)

            case (.fountains, false):
                try fountainsOn(true)
                try washroomsOn(false)

            case (.washrooms, true):
                try washroomsOn(false)

            case (.washrooms, false):
                try washroomsOn(true)
                try fountainsOn(false)

            default:
                return
            }
        }
    }

    private func fountainsOn(_ isOn: Bool) throws {
        try mapView &|> displaySupplementAnnotations(.fountain, isOn)
        fountainsButton.isOn = isOn
        fountainsButton.tintColor = secondaryTintColor(isOn)
    }

    private func washroomsOn(_ isOn: Bool) throws {
        try mapView &|> displaySupplementAnnotations(.washroom, isOn)
        washroomsButton.isOn = isOn
        washroomsButton.tintColor = secondaryTintColor(isOn)
    }

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
