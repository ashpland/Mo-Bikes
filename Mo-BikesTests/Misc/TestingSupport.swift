//
//  Generators.swift
//  Mo-BikesTests
//
//  Created by Andrew on 2018-02-22.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import Foundation
import MapKit
import AEXML
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

func generateStationData(_ name: String) -> StationData {
    return generateStationData(named: name)
}

func generateStationData(named name: String, _ slots: (bikes: Int, free: Int) = generateSlots()) -> StationData {
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

extension Array where Element: Hashable {
    func containsSameElements(as other: [Element]) -> Bool {
        return Set(self) == Set(other)
    }
}

extension SupplementAnnotation {
    override open func isEqual(_ object: Any?) -> Bool {
        if let other = object as? SupplementAnnotation,
            self.coordinate == other.coordinate,
            self.pointType == other.pointType {
            return true
        } else {
            return false
        }
    }

    override open var hash: Int {
        struct AnnotationHash: Hashable {
            let pointType: SupplementPointType
            let lat: Double
            let lon: Double

            init(_ coordinate: CLLocationCoordinate2D, _ pointType: SupplementPointType) {
                self.pointType = pointType
                self.lat = coordinate.latitude
                self.lon = coordinate.longitude
            }
        }

        return AnnotationHash(self.coordinate, self.pointType).hashValue
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
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

func makeXMLDoc() -> AEXMLDocument {
    let xmlDoc = AEXMLDocument(root: AEXMLElement(name: "kml"))
    var root = xmlDoc.root

    root
        &> addChild("Document")
        >>> addChild("Folder")

    return xmlDoc
}

func addChild(_ name: String, value: String? = nil) -> (inout AEXMLElement) -> AEXMLElement {
    return { parent in
        let child = AEXMLElement(name: name, value: value)
        parent.addChild(child)
        return child
    }
}

func addChild(_ element: AEXMLElement) -> (inout AEXMLElement) -> AEXMLElement {
    return { parent in
        parent.addChild(element)
        return element
    }
}

func makePointPlacemark() -> AEXMLElement {
    var placemark = AEXMLElement(name: "Placemark")
    placemark &> addChild("Point") >>> addChild("coordinates", value: "-123.125914,49.2663411,0.0")
    return placemark
}

func makeBikewayPlacemark() -> AEXMLElement {
    var placemark = AEXMLElement(name: "Placemark")
    placemark &> addChild("description", value: "Local Street<br>")
    placemark
        &> addChild("MultiGeometry")
        >>> addChild("LineString")
        >>> addChild("coordinates", value: "-123.166270453668,49.2710157338192,0.0 -123.166270454964,49.2710157104298,0.0 -123.16630123224,49.2701228944955,0.0 -123.166315536304,49.2696909217319,0.0 -123.166331107411,49.2692315180453,0.0")
    return placemark
}
