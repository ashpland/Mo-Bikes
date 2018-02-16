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
import RxCocoa

class MapViewModel {
    static let sharedInstance = MapViewModel()
    var bikesOrSlots: BikesOrSlots = .bikes
}

class StationAnnotation: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D
    let number: BehaviorSubject<String>
    
    init(_ station: Station) {
        self.title = station.name
        self.coordinate = CLLocationCoordinate2D(latitude: station.coordinate.lat, longitude: station.coordinate.lon)
        
        let number: String
        switch MapViewModel.sharedInstance.bikesOrSlots {
        case .bikes:
            number = String(station.availableBikes)
        case .slots:
            number = String(station.freeSlots)
        }
        
        self.number = BehaviorSubject<String>(value: number)
    }
}

class StationMarker: MKMarkerAnnotationView {
    
}

enum BikesOrSlots  {
    case bikes
    case slots
}

