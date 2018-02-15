//
//  StationManager.swift
//  Mo-Bikes
//
//  Created by Andrew on 2018-02-15.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import Foundation
import MapKit

class Station: NSObject, MKAnnotation{
    
    let name: String
    let coordinate: CLLocationCoordinate2D
    let totalSlots: Int
    let freeSlots: Int
    let availableBikes: Int
    let operative: Bool
    
    
    
    override init() {
        self.name = ""
        self.coordinate = CLLocationCoordinate2D.init()
        self.totalSlots = 0
        self.freeSlots = 0
        self.availableBikes = 0
        self.operative = false
        super.init()
    }
    
    
    
    
    
}


