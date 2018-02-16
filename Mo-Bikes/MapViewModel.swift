//
//  MapViewModel.swift
//  Mo-Bikes
//
//  Created by Andrew on 2018-02-15.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import Foundation
import MapKit
import RxSwift

class StationView: NSObject, MKAnnotation {
    let name: String
    let coordinate: CLLocationCoordinate2D
    let bikes: BehaviorSubject<Int>
    
    init(_ station: Station) {
        self.name = station.name
        self.coordinate = CLLocationCoordinate2D(latitude: station.coordinate.lat, longitude: station.coordinate.lon)
        self.bikes = BehaviorSubject<Int>(value: station.totalSlots)
    }
    
    
}

enum BikesOrSlots {
    case bikes
    case slots
}
