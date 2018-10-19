//
//  MapModel.swift
//  Mo-Bikes
//
//  Created by Andrew on 2018-02-15.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import MapKit
import Alamofire

enum BikesOrDocks {
    case bikes
    case docks
    
    var glyph: UIImage {
        switch self {
        case .bikes:
            return Styles.glyphs.bikes
        case .docks:
            return Styles.glyphs.docks
        }
    }
}

func getStationData(_ completionHandler: @escaping (DataResponse<Data>) -> Void) {
    Alamofire
        .request("https://vancouver-ca.smoove.pro/api-public/stations",
                 method: .get)
        .validate(statusCode: 200..<300)
        .validate(contentType: ["application/json"])
        .responseData(completionHandler: completionHandler)
}

func decodeStationData(response: DataResponse<Data>) -> [StationData]? {
    switch response.result {
    case .success(let data):
        if let stationData = StationData.decode(from: data) {
            return stationData
        } else {
            debugPrint(JSONError().localizedDescription)
            return nil
        }
    case .failure(let error):
        debugPrint(error.localizedDescription)
        return nil
    }
}

func update(existingStations: [Station]) -> ([StationData]?) -> (current: [Station], remove: [Station]) {
    return { updatedStationData in
        
        guard let updatedStationData = updatedStationData,
            !updatedStationData.isEmpty else { return ([Station](), [Station]()) }
        
        var currentStations = existingStations.asDictionary
        let updatedStations = updatedStationData.asDictionary
        let keysToRemove = currentStations.asSetOfKeys.subtracting(updatedStations.asSetOfKeys)
        
        let stationsToRemove = keysToRemove.compactMap { currentStations.removeValue(forKey: $0) }
        
        for station in currentStations {
            if let updatedData = updatedStations[station.key] {
                station.value.stationData = updatedData
            }
        }
        
        let keysToAdd = updatedStations.asSetOfKeys.subtracting(currentStations.asSetOfKeys)
        
        for key in keysToAdd {
            if let newStationData = updatedStations[key] {
                currentStations[key] = Station(newStationData)
            }
        }
        
        return (currentStations.map { $0.value}, stationsToRemove)
    }
}

protocol NameIndexable {
    var name: String { get }
}

extension Array where Element: NameIndexable {
    var asDictionary: [String: Element] {
        return self.reduce(into: [String: Element]()) { dictionary, element in
            dictionary[element.name] = element
        }
    }
}

extension Dictionary {
    var asSetOfKeys: Set<Key> {
        return Set(self.map({$0.key}))
    }
}

struct JSONError: LocalizedError {
    var errorDescription: String? {
        return "JSON Decoding Error"
    }
}
