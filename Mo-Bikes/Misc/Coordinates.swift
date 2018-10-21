//
//  Coordinates.swift
//  Mo-Bikes
//
//  Created by Andrew on 2018-10-16.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import MapKit

func stringToCLLocationCoordinate2D(_ coordinateString: PointCoordinate) -> CLLocationCoordinate2D {
    let split = coordinateString
        .split(separator: ",")
        .map { String($0.trimmingCharacters(in: .whitespaces)) }

    guard split.count >= 2,
        let first  = Double(split[0]),
        let second = Double(split[1]) else {
            return kCLLocationCoordinate2DInvalid
    }

    // Coordinate strings are different based on the source
    // KML:  -123.121817,49.274566,0.0
    // JSON: 49.274566,  -123.121817
    return (first, second) |> (split.count == 2 ? latFirst : lonFirst)
}

typealias LineCLLocationCoordinates = [CLLocationCoordinate2D]

func lineStringsToCLLocationCoordinate2D(_ lineCoordinates: LineCoordinates) -> LineCLLocationCoordinates {
    return lineCoordinates.map(stringToCLLocationCoordinate2D)
}

private func latFirst(first: Double, second: Double) -> CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: first, longitude: second)
}

private func lonFirst(first: Double, second: Double) -> CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: second, longitude: first)
}
