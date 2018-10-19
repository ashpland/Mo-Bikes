//
//  StationManager.swift
//  Mo-Bikes
//
//  Created by Andrew on 2018-02-15.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import MapKit

class Station: NSObject, MKAnnotation, NameIndexable {

    var stationData: StationData

    var name: String {
        return stationData.name
    }

    var coordinate: CLLocationCoordinate2D {
        return stationData.coordinates |> stringToCLLocationCoordinate2D
    }

    init(_ stationData: StationData) {
        self.stationData = stationData
    }
}

extension Station {
    override func isEqual(_ object: Any?) -> Bool {
        if let otherStation = object as? Station,
            self.stationData == otherStation.stationData {
            return true
        } else {
            return false
        }
    }

    override var hash: Int {
        return stationData.hashValue
    }
}

struct StationData: Decodable, NameIndexable, Hashable, Equatable {
    let name: String
    let coordinates: PointCoordinate
    let availableDocks: Int
    let availableBikes: Int

    enum CodingKeys: String, CodingKey {
        case name
        case coordinates
        case availableDocks = "free_slots"
        case availableBikes = "avl_bikes"
    }

    private struct StationDataList: Decodable {
        let result: [StationData]
    }

    static func decode(from data: Data) -> [StationData]? {
        return try? JSONDecoder().decode(StationDataList.self, from: data).result
    }

}
