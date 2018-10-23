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
    @IBOutlet weak var trayView: TrayView!
    @IBOutlet weak var trayStackView: UIStackView!
    @IBOutlet weak var trayBottomView: UIView!
    @IBOutlet weak var trayViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var paddingHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var hamburgerButton: MoButtonHamburger!
    @IBOutlet weak var washroomsButton: MoButtonWashrooms!
    @IBOutlet weak var fountainsButton: MoButtonFountains!

    var bikesOrDocksState: BikesOrDocks = .bikes {
        didSet {
            mapView |> refreshStationViews(with: bikesOrDocksState)
        }
    }

    var locationManager = CLLocationManager()

    // MARK: - TrayView math
    
    
    private var safeOffset: CGFloat {
        return view?.safeAreaInsets.bottom ?? 0.0
    }
    
    private let bounceHeight: CGFloat = 50
    
    private let trayCornerRadius: CGFloat = 20
    
    private var minimumClippedHeight: CGFloat {
        return trayCornerRadius + safeOffset
    }
    
    private var padding: CGFloat {
        return minimumClippedHeight + bounceHeight + safeOffset
    }
    
    private var bounceOpen: CGFloat {
        return -minimumClippedHeight
    }
    
    private var open: CGFloat {
        return bounceOpen - bounceHeight
    }
    
    private var closed: CGFloat {
        let numberOfViews = CGFloat(trayStackView.arrangedSubviews.count - 1)
        let spacing = trayStackView.spacing * numberOfViews
        let sum = padding
            + spacing
            + trayBottomView.frame.height
            + minimumClippedHeight
            - 3 * safeOffset

        return sum * -1
    }
    
    private var threshold: CGFloat {
        return ((open - closed) / 2) + closed
    }
    
    // MARK: - Methods
    
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
        trayView.delegate = self
        paddingHeightConstraint.constant = padding
        trayViewBottomConstraint.constant = closed
        trayBottomView.alpha = 0.0
        trayView.layer.cornerRadius = trayCornerRadius
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
                >>> refreshStationViews(with: bikesOrDocksState)
        }
    }

    @IBAction func topViewTapped(_ sender: UITapGestureRecognizer) {
        hamburgerButton.isOn.toggle()
        hamburgerButton.isOn |> openBottomDrawer
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
                hamburgerButton.isOn.toggle()
                hamburgerButton.isOn |> openBottomDrawer
            default:
                return
            }

    }

    private func openBottomDrawer(_ shouldOpen: Bool) {
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5) {
            self.trayViewBottomConstraint.constant = shouldOpen ? self.open : self.closed
            self.trayBottomView.alpha = shouldOpen ? 1.0 : 0.0
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

extension MapViewController: TrayViewDelegate {

    func trayViewTouchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let firstTouch = touches.first else { return }
        let deltaY = firstTouch.location(in: self.view).y - firstTouch.previousLocation(in: self.view).y
        let newConstant = trayViewBottomConstraint.constant - deltaY
        let newAlpha = (closed - newConstant) / closed
        switch newConstant {
        case bounceOpen...:
            trayViewBottomConstraint.constant = bounceOpen
            trayBottomView.alpha = 1
        case ..<closed:
            trayViewBottomConstraint.constant = closed
            trayBottomView.alpha = 0
        default:
            trayViewBottomConstraint.constant = newConstant
            trayBottomView.alpha = newAlpha
        }
    }
    
    func trayViewTouchesEnded() {
        let currentConstant = trayViewBottomConstraint.constant
        let endConstant = currentConstant < threshold ? closed : open
        let endAlpha: CGFloat = currentConstant < threshold ? 0 : 1
        UIView.animate(withDuration: 0.2) {
            self.trayViewBottomConstraint.constant = endConstant
            self.trayBottomView.alpha = endAlpha
            self.view.layoutIfNeeded()
        }
    }
    
}

let addAnnotationsTo = MKMapView.addAnnotations
let removeAnnotationsFrom = MKMapView.removeAnnotations


func displaySupplementAnnotations(_ pointType: SupplementPointType, _ turnOn: Bool) -> (inout MKMapView) throws -> Void {
    return { mapView in
        if turnOn {
            try pointType
                |> loadSupplementAnnotations
                >>> addAnnotationsTo(mapView)
        } else {
            mapView.annotations
                .compactMap(justAnnotations(of: pointType))
                |> removeAnnotationsFrom(mapView)
        }
    }
}

func callMobi() {
    if let url = URL(string: "tel://7786551800") {
        UIApplication.shared.open(url)
    }
}
