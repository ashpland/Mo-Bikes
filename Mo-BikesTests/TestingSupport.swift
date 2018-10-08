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

func generateSlots() -> (total: Int, bikes: Int, free: Int) {
    let uTotal = arc4random_uniform(99) + 1
    let total = Int(uTotal)
    let bikes = Int(arc4random_uniform(uTotal))
    let slots = total - bikes

    return (total, bikes, slots)
}

func generateStationData(_ name: String) -> StationData {
    let slots = generateSlots()
    let coordinate = generateLatLon()
    let coordinateString = "\(coordinate.lat), \(coordinate.lon)"

    return StationData(name: name,
                       coordinates: coordinateString,
                       totalDocks: slots.total,
                       availableDocks: slots.free,
                       availableBikes: slots.bikes,
                       operative: true)
}

func generateStationJSON(_ stationData: StationData) -> Data {
    let jsonString =  "{\"result\":[{\"name\":\"\(stationData.name)\",\"coordinates\":\"\(stationData.coordinates)\",\"total_slots\":\(stationData.totalDocks),\"free_slots\":\(stationData.availableDocks),\"avl_bikes\":\(stationData.availableBikes),\"operative\":\(stationData.operative),\"style\":\"\"}]}"

    return jsonString.data(using: .utf8)!
}

//func generateLatLon(in region: MKCoordinateRegion) -> (lat: Double, lon: Double) {
//    let latMax = UInt32(region.span.latitudeDelta * 1000000)
//    let lat = Double(arc4random_uniform(latMax)) / 1000000 + region.center.latitude - region.span.latitudeDelta / 2
//    let lonMax = UInt32(region.span.longitudeDelta * 1000000)
//    let lon = Double(arc4random_uniform(lonMax)) / 1000000 + region.center.longitude - region.span.longitudeDelta / 2
//    return (lat, lon)
//}
//
//

extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}

extension Station: Comparable {
    public static func <(lhs: Station, rhs: Station) -> Bool {
        return lhs.name < rhs.name
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

class FakeMapView: MKMapView {

    var annotationHolder = [MKAnnotation]()

    override func addAnnotation(_ annotation: MKAnnotation) {
        annotationHolder.append(annotation)
    }

    override func removeAnnotation(_ annotation: MKAnnotation) {
        if let index = annotations.index(where: { $0.coordinate == annotation.coordinate }) {
            annotationHolder.remove(at: index)
        }
    }
}
