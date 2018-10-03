//
//  StationManager.swift
//  Mo-Bikes
//
//  Created by Andrew on 2018-02-15.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import MapKit
import Alamofire
import RxSwift
import RxCocoa

final class Station: NSObject, MKAnnotation, ResponseObjectSerializable, ResponseCollectionSerializable {

    let name: String
    let coordinate: CLLocationCoordinate2D
    let totalDocks: Int
    let availableDocks: BehaviorRelay<Int>
    let availableBikes: BehaviorRelay<Int>
    
    init(name: String,
         coordinate: CLLocationCoordinate2D,
         totalSlots: Int,
         freeSlots: Int,
         availableBikes: Int) {
        self.name = name
        self.coordinate = coordinate
        self.totalDocks = totalSlots
        self.availableDocks = BehaviorRelay<Int>(value: freeSlots)
        self.availableBikes = BehaviorRelay<Int>(value: availableBikes)
    }
    
    required convenience init?(response: HTTPURLResponse, representation: Any) {
        guard let representation = representation as? [String: Any],
            let name = representation["name"] as? String,
            let coordinates = representation["coordinates"] as? String,
            let totalSlots = representation["total_slots"] as? Int,
            let freeSlots = representation["free_slots"] as? Int,
            let availableBikes = representation["avl_bikes"] as? Int,
            let isActive = representation["operative"] as? Bool,
            isActive == true
            else { return nil }
        
        let splitCoordinates = coordinates
            .split(separator: ",")
            .map { String($0.trimmingCharacters(in: .whitespaces)) }
        
        guard let latString = splitCoordinates.first,
            let lonString = splitCoordinates.last,
            let lat = Double(latString),
            let lon = Double(lonString)
            else { return nil }
        
        self.init(name: name,
                  coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                  totalSlots: totalSlots,
                  freeSlots: freeSlots,
                  availableBikes: availableBikes)
    }
    
    func updated(from newStation: Station) -> Station {
        self.availableDocks.accept(newStation.availableBikes.value)
        self.availableDocks.accept(newStation.availableDocks.value)
        return self
    }
}
