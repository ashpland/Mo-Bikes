//
//  MapDelegate.swift
//  Mo-Bikes
//
//  Created by Andrew on 2018-02-15.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import Foundation
import MapKit
import RxSwift


class MapDelgate: NSObject, MKMapViewDelegate {
    
    let disposeBag = DisposeBag()
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let station = annotation as? StationAnnotation {
            return station.marker()
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let marker = view as? StationMarker {
            marker.currentlySelected.onNext(true)
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if let marker = view as? StationMarker {
            marker.currentlySelected.onNext(false)
        }
    }
}
