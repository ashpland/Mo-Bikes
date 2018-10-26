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

    static func decode(from data: Data) throws -> [StationData] {
        return try JSONDecoder().decode(StationDataList.self, from: data).result
    }

}

class StationView: MKMarkerAnnotationView {
    var stationData: StationData!
    var bikesOrDocks: BikesOrDocks!
}

@discardableResult func configureStationView(_ bikesOrDocks: BikesOrDocks) -> (inout StationView) -> StationView {
    return { view in
        view.bikesOrDocks = bikesOrDocks
        view &|> setStationViewColor <> setStationViewText <> setStationViewImage
        view.animatesWhenAdded = true
        return view
    }
}

func setStationViewColor(for view: inout StationView) {
    view.markerTintColor = view[keyPath: view.bikesOrDocks.available] |> markerColor
}

func setStationViewText(for view: inout StationView) {
    view.glyphText = view.isSelected ? String(view[keyPath: view.bikesOrDocks.available]) : nil
}

func setStationViewImage(for view: inout StationView) {
    view.glyphImage = view.isSelected ? nil : view.bikesOrDocks.glyphImage
}
