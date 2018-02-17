//
//  StationManager.swift
//  Mo-Bikes
//
//  Created by Andrew on 2018-02-15.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import Foundation
import MapKit
import Alamofire
import RxSwift

class StationManager {
    static let sharedInstance = StationManager()
    
    var stations = [Station]()
    
    init() {
        NetworkManager.sharedInstance.updateStationData { (stations) in
            self.stations = stations
            MapViewModel.sharedInstance.display(stations)
        }
    }
}

final class Station: NSObject, ResponseObjectSerializable, ResponseCollectionSerializable {
    
    let name: String
    let coordinate: (lat: Double, lon: Double)
    let totalSlots: Int
    let freeSlots: BehaviorSubject<Int>
    let availableBikes: BehaviorSubject<Int>
    let operative: Bool
    
    init(name: String, coordinate: (lat: Double, lon: Double), totalSlots: Int, freeSlots: Int, availableBikes: Int, operative: Bool) {
        self.name = name
        self.coordinate = coordinate
        self.totalSlots = totalSlots
        self.freeSlots = BehaviorSubject<Int>(value: freeSlots)
        self.availableBikes = BehaviorSubject<Int>(value: availableBikes)
        self.operative = operative
        
        super.init()
    }
    
    required init?(response: HTTPURLResponse, representation: Any) {
        guard let representation = representation as? [String: Any],
        let name = representation["name"] as? String,
        let coord = representation["coordinates"] as? String,
            let lat = Double(coord[...coord.index(coord.startIndex, offsetBy: 8)]),
            let lon = Double(coord[coord.index(coord.endIndex, offsetBy: -11)...]),
        let totalSlots = representation["total_slots"] as? Int,
        let freeSlots = representation["free_slots"] as? Int,
        let availableBikes = representation["avl_bikes"] as? Int,
        let operative = representation["operative"] as? Bool
        else { return nil }
        
        self.name = name
        self.coordinate = (lat, lon)
        self.totalSlots = totalSlots
        self.freeSlots = BehaviorSubject<Int>(value: freeSlots)
        self.availableBikes = BehaviorSubject<Int>(value: availableBikes)
        self.operative = operative
        
        super.init()
    }
}


/*
 NSString *latString = [coordinatesString substringToIndex:9];
 NSString *lonString = [coordinatesString substringFromIndex:(coordinatesString.length - 11)];

 
 */

/*
 "name":"0001 10th & Cambie
 "coordinates":"49.262487, -123.114397"
 "total_slots":52,
 "free_slots":32,
 "avl_bikes":20,
 "operative":true,
 "style":""
*/

/*
guard
    let username = response.url?.lastPathComponent,
    let representation = representation as? [String: Any],
    let name = representation["name"] as? String
    else { return nil }

self.username = username
self.name = name


*/
