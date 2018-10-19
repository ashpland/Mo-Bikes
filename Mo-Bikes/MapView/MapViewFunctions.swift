//
//  MapViewFunctions.swift
//  Mo-Bikes
//
//  Created by Andrew on 2018-10-18.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import MapKit

func setupMapView(delegate: MKMapViewDelegate) -> (inout MKMapView) -> Void {
    return { mapView in
        mapView.delegate = delegate
        mapView.register(StationView.self, forAnnotationViewWithReuseIdentifier: "\(StationView.self)")
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "\(SupplementPointType.self)")
        do {
            mapView.addOverlays(try loadBikeways(), level: .aboveRoads)
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
}

func setupLocationManager(_ locationManager: inout CLLocationManager) {
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
}

func zoomTo(_ location: CLLocation?) -> (inout MKMapView) -> Void {
    return { mapView in
        guard let location = location else { return }
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
