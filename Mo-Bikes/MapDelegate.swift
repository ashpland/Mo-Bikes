//
//  MapDelegate.swift
//  Mo-Bikes
//
//  Created by Andrew on 2018-02-15.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import Foundation
import MapKit

class MapDelgate: NSObject, MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is StationAnnotation {
            let station = annotation as! StationAnnotation
            return station.marker()
        }
        
        
        return nil
    }
}
