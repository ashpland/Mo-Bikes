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
        
        if annotation is StationAnnotation {
            let station = annotation as! StationAnnotation
            return station.marker()
        }
        return nil
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view is StationMarker {
            let marker = view as! StationMarker
            if marker.annotation is StationAnnotation {
                let station = marker.annotation as! StationAnnotation
                station.number.subscribe(onNext: {marker.glyphText = String($0)})
                .disposed(by: self.disposeBag)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view is StationMarker {
            let marker = view as! StationMarker
            marker.glyphText = nil
        }
    }
}
