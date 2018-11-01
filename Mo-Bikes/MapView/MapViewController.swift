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

    @IBOutlet weak var menuButton: MoButtonMenu!
    @IBOutlet weak var washroomsButton: MoButtonWashrooms!
    @IBOutlet weak var fountainsButton: MoButtonFountains!
    @IBOutlet weak var bikesButton: MoButtonBikes!
    @IBOutlet weak var docksButton: MoButtonDocks!

    var bikesOrDocksState: BikesOrDocks = .bikes {
        didSet {
            mapView |> refreshStationViews(with: bikesOrDocksState)
        }
    }

    var locationManager = CLLocationManager()

    // MARK: - TrayView math

    private let bounceHeight = Styles.bounceHeight
    private let trayCornerRadius = Styles.trayCornerRadius

    private var safeOffset: CGFloat {
        return view?.safeAreaInsets.bottom ?? 0.0
    }

    private var minimumClippedHeight: CGFloat {
        return trayCornerRadius + safeOffset
    }

    private var padding: CGFloat {
        return minimumClippedHeight + bounceHeight + safeOffset
    }

    var bounceOpenHeight: CGFloat {
        return -minimumClippedHeight
    }

    var openHeight: CGFloat {
        return bounceOpenHeight - bounceHeight
    }

    var closedHeight: CGFloat {
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
        return ((openHeight - closedHeight) / 2) + closedHeight
    }

    // MARK: - Setup

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        setupView()
        startUpdatingStations()
    }

    private func setupMap() {
        locationManager &> setupLocationManager
        doCatchPrint {
            try mapView &> setupMapView(delegate: self) <> zoomTo(locationManager.location)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(MapViewController.handleMapTap))
        tap.cancelsTouchesInView = false
        mapView.addGestureRecognizer(tap)
    }

    private func setupView() {
        trayView.delegate = self
        paddingHeightConstraint.constant = padding
        trayViewBottomConstraint.constant = closedHeight
        trayBottomView.alpha = 0.0

        trayView
            &> blurBackground
            <> roundCorners(trayCornerRadius)
            <> addBorder(Styles.border)

        setBikesAndDocsButtons(selected: .bikes)
    }

    // MARK: - Station Updating

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

    // MARK: - UI Handling

    @objc func handleMapTap() {
        if menuButton.isOn == true {
            menuButton.isOn = false
            setTrayOpen(false)
        }
    }

    @IBAction func topViewTapped(_ sender: UITapGestureRecognizer) {
        handleMenuButton()
    }

    @IBAction func buttonPressed(_ sender: MoButton) {
            switch sender.type {
            case .bikes:
                .bikes
                    |> setBikesAndDocsButtons
                    >>> set(\.bikesOrDocksState, on: self)
            case .docks:
                .docks
                    |> setBikesAndDocsButtons
                    >>> set(\.bikesOrDocksState, on: self)
            case .fountains, .washrooms:
                handleSupplementAnnotations(for: sender)
            case .contact:
                callMobi()
            case .compass:
                doCatchPrint {
                    try self.mapView &> zoomTo(locationManager.location)
                }
            case .menu:
                handleMenuButton()
            default:
                return
            }
    }

    // MARK: - State management

    @discardableResult func setBikesAndDocsButtons(selected state: BikesOrDocks) -> BikesOrDocks {
        switch state {
        case .bikes:
            bikesButton |> setButtonImage(to: \.bikesSelected)
            docksButton |> setButtonImage(to: \.docksUnselected )
        case .docks:
            bikesButton |> setButtonImage(to: \.bikesUnselected)
            docksButton |> setButtonImage(to: \.docksSelected )
        }
        return state
    }

    func handleMenuButton() {
        menuButton.isOn.toggle()
        menuButton.isOn |> setTrayOpen
    }

    private func setTrayOpen(_ shouldOpen: Bool) {
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5) {
            shouldOpen ? .open(self) : .closed(self) |> self.setTrayState
            self.view.layoutIfNeeded()
        }
    }

    private func setTrayState(_ trayState: TrayState) {
        trayViewBottomConstraint.constant = trayState.constant
        trayBottomView.alpha = trayState.alpha
        menuButton |> setRotate(trayState.rotation |> inRadians)
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
        try mapView &> annotations(pointType: .fountain, isOn: isOn, button: fountainsButton)
    }

    private func washroomsOn(_ isOn: Bool) throws {
        try mapView &> annotations(pointType: .washroom, isOn: isOn, button: washroomsButton)
    }

}

// MARK: - TrayViewDelegate

extension MapViewController: TrayViewDelegate {
    func trayViewTouchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let firstTouch = touches.first else { return }
        let deltaY = firstTouch.location(in: self.view).y - firstTouch.previousLocation(in: self.view).y
        let newConstant = trayViewBottomConstraint.constant - deltaY
        let newAlpha = (closedHeight - newConstant) / closedHeight
        let newRotation = newAlpha * 90

        switch newConstant {
        case bounceOpenHeight...:
            setTrayState(.bounceOpen(self))
        case ..<closedHeight:
            setTrayState(.closed(self))
        default:
            setTrayState(.partial(bottomConstant: newConstant,
                                   alpha: newAlpha,
                                   iconRotation: newRotation))
        }
    }

    func trayViewTouchesEnded() {
        self.trayViewBottomConstraint.constant > self.threshold
            |> set(\.menuButton!.isOn, on: self)
            >>> setTrayOpen
    }
}
