//
//  MapViewFunctions.swift
//  Mo-Bikes
//
//  Created by Andrew on 2018-10-18.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import MapKit

func setupMapView(delegate: MKMapViewDelegate) -> (inout MKMapView) throws -> Void {
    return { mapView in
        mapView.delegate = delegate
        mapView.register(StationView.self, forAnnotationViewWithReuseIdentifier: "\(StationView.self)")
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "\(SupplementPointType.self)")
        mapView.addOverlays(try loadBikeways(), level: .aboveRoads)
    }
}

func setupLocationManager(_ locationManager: inout CLLocationManager) {
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
}

func zoomTo(_ location: CLLocation?) -> (inout MKMapView) throws -> Void {
    return { mapView in
        guard let location = location else { throw MapError.noLocation }
        let region = MKCoordinateRegion(center: location.coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007))

        mapView.setRegion(region, animated: true)
    }
}

func getStations(from mapView: MKMapView) -> [Station] {
    return mapView.annotations.compactMap { $0 as? Station }
}

func update(mapView: inout MKMapView) -> ((current: [Station], remove: [Station])) -> MKMapView {
    let mapView = mapView
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

func annotations(pointType: SupplementPointType, isOn: Bool, button: MoButtonToggle) -> (inout MKMapView) throws -> Void {
    return { mapView in
        try mapView &|> displaySupplementAnnotations(pointType, isOn)
        button.isOn = isOn
        button.tintColor = secondaryTintColor(isOn)
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
