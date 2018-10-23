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
        switch annotation {

        case let station as Station:
            return mapView |> dequeueStationView(with: station) >>> configureStationView(bikesOrDocksState)

        case let supplement as SupplementAnnotation:
            return mapView |> dequeueSupplementView >>> configureMarker(for: supplement)

        default:
            return nil
        }
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if var stationView = view as? StationView {
            stationView &|> setText
        }
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if var stationView = view as? StationView {
            stationView &|> setImage <> setText
        }
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let supplementPolyline = overlay as? SupplementPolyline {
            return supplementPolyline |> makePolylineRenderer
        } else {
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

func dequeueStationView(with station: Station) -> (MKMapView) -> StationView {
    return { mapView in
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: "\(StationView.self)") as! StationView
        view.stationData = station.stationData
        return view
    }
}

func dequeueSupplementView(_ mapView: MKMapView) -> MKMarkerAnnotationView {
    return mapView.dequeueReusableAnnotationView(withIdentifier: "\(SupplementPointType.self)") as! MKMarkerAnnotationView
}
