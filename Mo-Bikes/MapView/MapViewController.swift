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

    @IBOutlet weak var trayView: UIView!
    @IBOutlet weak var trayStackView: UIStackView!
    @IBOutlet weak var trayBottomView: UIStackView!
    @IBOutlet weak var trayViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var hamburgerButton: MoButtonHamburger!
    
    private var bottomOffset: CGFloat {
        return (trayStackView.spacing + trayBottomView.frame.height + 20) * -1
    }
    
    let locationManager = CLLocationManager()
    let viewModel = MapViewModel()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupLocation()
        setupMap()
        setupRx()
        
        trayViewBottomConstraint.constant = bottomOffset
        trayBottomView.alpha = 0.0
        
        trayView.layer.cornerRadius = 20

    }

    private func setupLocation() {
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        zoomToCurrent()
    }

    private func zoomToCurrent() {
        guard let currentLocation = self.locationManager.location else {
            debugPrint("Can't get current location")
            return
        }

        let currentRegion = MKCoordinateRegion(center: currentLocation.coordinate,
                                               span: MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007))

        mapView.setRegion(currentRegion, animated: true)
    }

    private func setupMap() {
        mapView.register(StationView.self, forAnnotationViewWithReuseIdentifier: "\(StationView.self)")
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "\(SupplementPointType.self)")
        do {
            mapView.addOverlays(try loadBikeways(), level: .aboveRoads)
        }
        catch {
            debugPrint(error.localizedDescription)
        }
    }

    private func setupRx() {
        viewModel.stationsToAddDriver
            .drive(mapView.rx.addAnnotations)
            .disposed(by: disposeBag)

        viewModel.stationsToRemoveSignal
            .emit(to: mapView.rx.removeAnnotation)
            .disposed(by: disposeBag)

        Signal<Int>
            .timer(0, period: 60)
            .asObservable()
            .flatMap { _ in self.updateStations() }
            .bind(to: viewModel.rx.updateStations)
            .disposed(by: disposeBag)
    }

    private func updateStations() -> Observable<[StationData]> {
        return viewModel
            .getStationData()
            .asDriver(onErrorRecover: { error -> SharedSequence<DriverSharingStrategy, [StationData]> in
                print(error.localizedDescription) // TODO: User facing error handling
                return Driver.just([StationData]())
            })
            .asObservable()
    }
    
    @IBAction func topViewTapped(_ sender: UITapGestureRecognizer) {
        hamburgerButton |> openBottomDrawer
    }
    
    @IBAction func buttonPressed(_ sender: MoButton) {
        switch sender.type {
        case .bikes:
            viewModel.bikesOrDocks.accept(.bikes)
        case .docks:
            viewModel.bikesOrDocks.accept(.docks)
        case .fountains, .washrooms:
            sender as? MoButtonToggle |> displaySupplementAnnotations
        case .contact:
            callMobi()
        case .compass:
            zoomToCurrent()
        case .hamburger:
            sender as? MoButtonToggle |> openBottomDrawer
        default:
            return
        }
    }
    
    private func displaySupplementAnnotations(_ toggle: MoButtonToggle?) {
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
            try? pointType
                |> loadSupplementAnnotations
                >>> mapView.addAnnotations
        }
        
        toggle.isOn.toggle()
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

    private func callMobi() {
        if let url = URL(string: "tel://7786551800") {
            UIApplication.shared.open(url)
        }
    }

}
