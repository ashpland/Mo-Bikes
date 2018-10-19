//
//  MapViewFunctions.swift
//  Mo-Bikes
//
//  Created by Andrew on 2018-10-18.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import MapKit

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

func setup(locationManager: CLLocationManager) {
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
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
