//
//  MapViewDelegate.swift
//  Mo-Bikes
//
//  Created by Andrew on 2018-10-17.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import MapKit

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let station = annotation as? Station {
            let stationView = mapView.dequeueReusableAnnotationView(withIdentifier: "\(StationView.self)") as! StationView
            stationView.viewModel = StationViewModel(station: station,
                                                     bikesOrDocksState: viewModel.bikesOrDocks.asDriver())
            return stationView
        } else if let supplement = annotation as? SupplementAnnotation {
            return mapView |> dequeueSupplementView >>> configureMarker(for: supplement)
        } else {
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let stationView = view as? StationView {
            stationView.viewModel.stationIsSelected.accept(true)
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if let stationView = view as? StationView {
            stationView.viewModel.stationIsSelected.accept(false)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let supplementPolyline = overlay as? SupplementPolyline {
            return supplementPolyline |> configurePolylineRenderer
        } else {
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}


func dequeueStationView(_ mapView: MKMapView) -> StationView {
    return mapView.dequeueReusableAnnotationView(withIdentifier: "\(StationView.self)") as! StationView
}

func dequeueSupplementView(_ mapView: MKMapView) -> MKMarkerAnnotationView {
    return mapView.dequeueReusableAnnotationView(withIdentifier: "\(SupplementPointType.self)") as! MKMarkerAnnotationView
}
