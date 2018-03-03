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
    
    let stations: BehaviorSubject<Array<Station>>
    
    init() {
        self.stations = BehaviorSubject<Array<Station>>(value: [Station]())
    }
    
    func update(_ stations: [Station]) {
        let activeStations = stations.filter{$0.getOperative()}
        do {
            let updatedStations = try self.stations.value()
                .dictionary()
                .update(from: activeStations.dictionary(), onRemove: {$0.operative.onNext(false)}, sync: {return $0.sync($1)})
                .map({$0.value})
            
            self.stations.onNext(updatedStations)
        }
        catch {
            print("Could not get current value of stations array")
        }
    }
}

final class Station: NSObject, ResponseObjectSerializable, ResponseCollectionSerializable {
    
    let name: String
    let coordinate: (lat: Double, lon: Double)
    let totalSlots: Int
    let freeSlots: BehaviorSubject<Int>
    let availableBikes: BehaviorSubject<Int>
    let operative: BehaviorSubject<Bool>
    
    init(name: String, coordinate: (lat: Double, lon: Double), totalSlots: Int, freeSlots: Int, availableBikes: Int, operative: Bool) {
        self.name = name
        self.coordinate = coordinate
        self.totalSlots = totalSlots
        self.freeSlots = BehaviorSubject<Int>(value: freeSlots)
        self.availableBikes = BehaviorSubject<Int>(value: availableBikes)
        self.operative = BehaviorSubject<Bool>(value: operative)
        
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
    
    func sync(_ update: Station) -> Station {
        do {
            let updateBikes = try update.availableBikes.value()
            self.freeSlots.onNext(updateBikes)
            let updateSlots = try update.freeSlots.value()
            self.freeSlots.onNext(updateSlots)
        }
        catch { print("Could not update station data for \(self.name)") }
        
        return self
    }
    
    func getOperative() -> Bool {
        do {
            return try self.operative.value()
        }
        catch {
            print("Can't get current operative value for station \(self.name)")
        }
        return false
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
