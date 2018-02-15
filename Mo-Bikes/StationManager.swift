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

final class Station: NSObject, MKAnnotation, ResponseObjectSerializable, ResponseCollectionSerializable {
    
    let name: String
    let coordinate: CLLocationCoordinate2D
    let totalSlots: Int
    let freeSlots: Int
    let availableBikes: Int
    let operative: Bool
    
    init(name: String, coordinate: CLLocationCoordinate2D, totalSlots: Int, freeSlots: Int, availableBikes: Int, operative: Bool) {
        self.name = name
        self.coordinate = coordinate
        self.totalSlots = totalSlots
        self.freeSlots = freeSlots
        self.availableBikes = availableBikes
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
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        self.totalSlots = totalSlots
        self.freeSlots = freeSlots
        self.availableBikes = availableBikes
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
