//
//  Generators.swift
//  Mo-BikesTests
//
//  Created by Andrew on 2018-02-22.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import Foundation
import MapKit
@testable import Mo_Bikes

func generateLatLon() -> (lat: Double, lon: Double) {
    let lat = Double(arc4random_uniform(90*1000000)) / 1000000
    let lon = Double(Int(arc4random_uniform(360*1000000)) - 180*1000000) / 1000000
    return (lat, lon)
}

func generateSlots() -> (bikes: Int, free: Int) {
    let uTotal = arc4random_uniform(99) + 1
    let total = Int(uTotal)
    let bikes = Int(arc4random_uniform(uTotal))
    let slots = total - bikes

    return (bikes, slots)
}

func generateStationData(_ name: String, _ slots: (bikes: Int, free: Int) = generateSlots()) -> StationData {
    let coordinate = generateLatLon()
    let coordinateString = "\(coordinate.lat), \(coordinate.lon)"

    return StationData(name: name,
                       coordinates: coordinateString,
                       availableDocks: slots.free,
                       availableBikes: slots.bikes)
}

func generateStationJSON(_ stationData: StationData) -> Data {
    let jsonString =  "{\"result\":[{\"name\":\"\(stationData.name)\",\"coordinates\":\"\(stationData.coordinates)\",\"total_slots\":0,\"free_slots\":\(stationData.availableDocks),\"avl_bikes\":\(stationData.availableBikes),\"operative\":true,\"style\":\"\"}]}"

    return jsonString.data(using: .utf8)!
}

extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}

//extension Station: Comparable {
//    public static func <(lhs: Station, rhs: Station) -> Bool {
//        return lhs.name < rhs.name
//    }
//}

extension CLLocationCoordinate2D: Equatable {
    public static func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

class FakeMapView: MKMapView {

    var annotationHolder = [MKAnnotation]()

    override func addAnnotations(_ annotations: [MKAnnotation]) {
        annotationHolder += annotations
    }

    override func removeAnnotations(_ annotations: [MKAnnotation]) {
        for annotation in annotations {
            if let index = annotations.index(where: { $0.coordinate == annotation.coordinate }) {
                annotationHolder.remove(at: index)
            }
        }
    }
}

func imagesAreSame(lhs: UIImage?, rhs: UIImage?) -> Bool {
    if let lhs = lhs,
        let rhs = rhs,
        let lhsData = lhs.pngData(),
        let rhsData = rhs.pngData() {
        return lhsData == rhsData
    }
    return false
}
