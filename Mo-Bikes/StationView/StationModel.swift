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

final class Station: NSObject, MKAnnotation, NameIndexable {

    var stationData: StationData {
        didSet {
            availableDocks.accept(stationData.availableDocks)
            availableBikes.accept(stationData.availableBikes)
        }
    }

    var name: String {
        return stationData.name
    }

    var coordinate: CLLocationCoordinate2D {
        let splitCoordinates = stationData.coordinates
            .split(separator: ",")
            .map { String($0.trimmingCharacters(in: .whitespaces)) }

        guard let latString = splitCoordinates.first,
            let lonString = splitCoordinates.last,
            let lat = Double(latString),
            let lon = Double(lonString)
            else { return kCLLocationCoordinate2DInvalid }

        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    var availableDocksDriver: Driver<Int> {
        return availableDocks.asDriver().distinctUntilChanged()
    }

    var availableBikesDriver: Driver<Int> {
        return availableBikes.asDriver().distinctUntilChanged()
    }

    private let availableDocks: BehaviorRelay<Int>
    private let availableBikes: BehaviorRelay<Int>

    init(_ stationData: StationData) {
        self.stationData = stationData
        self.availableDocks = BehaviorRelay<Int>(value: stationData.availableDocks)
        self.availableBikes = BehaviorRelay<Int>(value: stationData.availableBikes)
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
    let coordinates: String
    let totalDocks: Int
    let availableDocks: Int
    let availableBikes: Int
    let operative: Bool

    enum CodingKeys: String, CodingKey {
        case name
        case coordinates
        case totalDocks = "total_slots"
        case availableDocks = "free_slots"
        case availableBikes = "avl_bikes"
        case operative
    }

    private struct StationDataList: Decodable {
        let result: [StationData]
    }

    static func decode(from data: Data) -> [StationData]? {
        return try? JSONDecoder().decode(StationDataList.self, from: data).result
    }

}
