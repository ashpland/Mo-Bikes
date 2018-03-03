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
import RxCocoa

class StationManager {
    static let sharedInstance = StationManager()
    
    let stations: BehaviorRelay<Array<Station>>
    
    init() {
        self.stations = BehaviorRelay<Array<Station>>(value: [Station]())
    }
    
    func update(_ stations: [Station]) {
        let activeStations = stations.filter{$0.operative.value}
        let updatedStations = self.stations.value
            .dictionary()
            .update(from: activeStations.dictionary(),
                    onRemove: {$0.operative.accept(false)},
                    sync: {return $0.update(from: $1)})
            .map({$0.value})
        
        self.stations.accept(updatedStations)
    }
}

final class Station: NSObject, ResponseObjectSerializable, ResponseCollectionSerializable {
    
    let name: String
    let coordinate: (lat: Double, lon: Double)
    let totalSlots: Int
    let freeSlots: BehaviorRelay<Int>
    let availableBikes: BehaviorRelay<Int>
    let operative: BehaviorRelay<Bool>
    
    init(name: String,
         coordinate: (lat: Double, lon: Double),
         totalSlots: Int,
         freeSlots: Int,
         availableBikes: Int,
         operative: Bool) {
        self.name = name
        self.coordinate = coordinate
        self.totalSlots = totalSlots
        self.freeSlots = BehaviorRelay<Int>(value: freeSlots)
        self.availableBikes = BehaviorRelay<Int>(value: availableBikes)
        self.operative = BehaviorRelay<Bool>(value: operative)
        
        super.init()
    }
    
    required convenience init?(response: HTTPURLResponse, representation: Any) {
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
        
        
        self.init(name: name,
                  coordinate: (lat, lon),
                  totalSlots: totalSlots,
                  freeSlots: freeSlots,
                  availableBikes: availableBikes,
                  operative: operative)
    }
    
    func update(from newStation: Station) -> Station {
        self.freeSlots.accept(newStation.availableBikes.value)
        self.freeSlots.accept(newStation.freeSlots.value)
        return self
    }
}

extension Array where Element == Station {
    func dictionary() -> [String : Station] {
        return self.reduce([String : Station](), { (dict, station) -> [String : Station] in
            return dict.merging([station.name : station], uniquingKeysWith: {$1})
        })
    }
}

extension Dictionary {
    func keySet() -> Set<Key> {
        return Set(self.map({$0.key}))
    }
    
    func update(from update: Dictionary<Key, Value>,
                onRemove: (Value) -> Void,
                sync: (Value, Value) throws -> Value) -> Dictionary<Key, Value>
    {
        let keysToRemove = self.keySet().subtracting(update.keySet())
        var updatedDict = self
        
        for key in keysToRemove {
            if let removeValue = updatedDict.removeValue(forKey: key) {
                onRemove(removeValue)
            }
        }
        
        do {
            try updatedDict.merge(update, uniquingKeysWith: sync)
        }
        catch {
            print("Could not merge dictionaries")
        }
        
        return updatedDict
    }
}
