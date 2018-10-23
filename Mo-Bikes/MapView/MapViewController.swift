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
            &|> blurBackground
            <> roundCorners(trayCornerRadius)
            <> addBorder(Styles.border)

        setBikesAndDocsButtons(selected: .bikes)
    }

    func disableHighlighting(_ button: inout UIButton) {
        button.adjustsImageWhenHighlighted = false
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

    @objc func handleMapTap() {
        if menuButton.isOn == true {
            menuButton.isOn = false
            openBottomDrawer(false)
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
                    try self.mapView &|> zoomTo(locationManager.location)
                }
            case .menu:
                handleMenuButton()
            default:
                return
            }
    }

    @discardableResult func setBikesAndDocsButtons(selected state: BikesOrDocks) -> BikesOrDocks {
        switch state {
        case .bikes:
            bikesButton.setImage(#imageLiteral(resourceName: "bikeIcon-invert"), for: .normal)
            docksButton.setImage(#imageLiteral(resourceName: "dockIcon"), for: .normal)
        case .docks:
            bikesButton.setImage(#imageLiteral(resourceName: "bikeIcon"), for: .normal)
            docksButton.setImage(#imageLiteral(resourceName: "dockIcon-invert"), for: .normal)
        }
        return state
    }

    func handleMenuButton() {
        menuButton.isOn.toggle()
        menuButton.isOn |> openBottomDrawer
    }

    private func openBottomDrawer(_ shouldOpen: Bool) {
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5) {
            shouldOpen ? .open(self) : .closed(self)
                |> self.setTrayValues
            self.view.layoutIfNeeded()
        }
    }

    private func setTrayValues(_ trayState: TrayState) {
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
        try mapView &|> annotations(pointType: .fountain, isOn: isOn, button: fountainsButton)
    }

    private func washroomsOn(_ isOn: Bool) throws {
        try mapView &|> annotations(pointType: .washroom, isOn: isOn, button: washroomsButton)
    }

}

extension MapViewController: TrayViewDelegate {
    func trayViewTouchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let firstTouch = touches.first else { return }
        let deltaY = firstTouch.location(in: self.view).y - firstTouch.previousLocation(in: self.view).y
        let newConstant = trayViewBottomConstraint.constant - deltaY
        let newAlpha = (closedHeight - newConstant) / closedHeight
        let newRotation = newAlpha * 90

        switch newConstant {
        case bounceOpenHeight...:
            setTrayValues(.bounceOpen(self))
        case ..<closedHeight:
            setTrayValues(.closed(self))
        default:
            setTrayValues(.partial(bottomConstant: newConstant,
                                   alpha: newAlpha,
                                   iconRotation: newRotation))
        }
    }

    func trayViewTouchesEnded() {
        self.trayViewBottomConstraint.constant > self.threshold
            |> set(\.menuButton!.isOn, on: self)
            >>> openBottomDrawer
    }
}

enum TrayState {
    case bounceOpen(_ mvc: MapViewController)
    case open(_ mvc: MapViewController)
    case closed(_ mvc: MapViewController)
    case partial(bottomConstant: CGFloat, alpha: CGFloat, iconRotation: CGFloat)

    var constant: CGFloat {
        switch self {
        case .bounceOpen(let mvc):
            return mvc.bounceOpenHeight
        case .open(let mvc):
            return mvc.openHeight
        case .closed(let mvc):
            return mvc.closedHeight
        case .partial(let bottomConstant, _, _):
            return bottomConstant
        }
    }

    var alpha: CGFloat {
        switch self {
        case .bounceOpen, .open:
            return 1.0
        case .closed:
            return 0.0
        case .partial(_, let alpha, _):
            return alpha
        }
    }

    var rotation: CGFloat {
        switch self {
        case .bounceOpen, .open:
            return 90.0
        case .closed:
            return 0.0
        case .partial(_, _, let iconRotation):
            return iconRotation
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
