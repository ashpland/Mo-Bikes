//
//  SupplementModels.swift
//  Mo-Bikes
//
//  Created by Andrew on 2018-10-16.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import MapKit

// MARK: Points

enum SupplementPointType: String, CaseIterable {
    case fountain = "drinking_fountains"
    case washroom = "public_washrooms"

    var fileURL: URL {
        return Bundle.main.url(forResource: self.rawValue, withExtension: "kml")!
    }

    var glyphImage: UIImage {
        switch self {
        case .fountain:
            return #imageLiteral(resourceName: "fountain")
        case .washroom:
            return #imageLiteral(resourceName: "toilet")
        }
    }
}

class SupplementAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let pointType: SupplementPointType

    init(coordinate: CLLocationCoordinate2D, pointType: SupplementPointType) {
        self.coordinate = coordinate
        self.pointType = pointType
        super.init()
    }
}

func stringToAnnotation(of pointType: SupplementPointType) -> (String) -> SupplementAnnotation {
    return { string in
        return SupplementAnnotation(coordinate: string |> stringToCLLocationCoordinate2D,
                                    pointType: pointType)
    }
}

func justAnnotations(of pointType: SupplementPointType) -> (MKAnnotation) -> SupplementAnnotation? {
    return { annotation in
        if let supplementAnnotation = annotation as? SupplementAnnotation,
            supplementAnnotation.pointType == pointType {
            return supplementAnnotation
        } else {
            return nil
        }
    }
}

// MARK: - Lines

enum SupplementLineType {
    case bikeRouteSolid
    case bikeRouteDashed
}

struct Bikeway {
    let lineType: SupplementLineType
    let lines: [LineCoordinates]

    static var fileURL: URL {
        return Bundle.main.url(forResource: "bikeways", withExtension: "kml")!
    }
}

class SupplementPolyline: MKPolyline {
    var lineType: SupplementLineType!
}

func bikewayToPolylines(_ bikeway: Bikeway) -> [SupplementPolyline] {
    return bikeway.lines.map { lineStrings in
        let coordinates = lineStrings |> lineStringsToCLLocationCoordinate2D
        let new = SupplementPolyline(coordinates: coordinates, count: coordinates.count)
        new.lineType = bikeway.lineType
        return new
    }
}

func extractLineType(from description: String) -> SupplementLineType? {
    guard let typeString = description
        .split(separator: "<",
               maxSplits: 1,
               omittingEmptySubsequences: true)
        .first else {
            return nil
    }

    switch typeString {
    case "Protected Bike Lanes", "Local Street":
        return .bikeRouteSolid
    case "Painted Lanes":
        return .bikeRouteDashed
    default:
        return nil
    }
}

// MARK: -

func loadSupplementAnnotations(of pointType: SupplementPointType) throws -> [MKAnnotation] {
    return try pointType.fileURL
        |>  getXMLDocument
        >>> getPlacemarkElements
        >>> compactMap(getPointCoordinateString)
        >>> map(stringToAnnotation(of: pointType))
}

func loadBikeways() throws -> [MKPolyline] {
    return try Bikeway.fileURL
        |>  getXMLDocument
        >>> getPlacemarkElements
        >>> compactMap(getBikeway)
        >>> map(bikewayToPolylines)
        >>> flattenArrays
}
