//
//  Bikeway.swift
//  Mo-Bikes
//
//  Created by Andrew on 2018-10-18.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import MapKit

// MARK: LineType

enum SupplementLineType {
    case bikeRouteSolid
    case bikeRouteDashed
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

// MARK: - Bikeway

struct Bikeway {
    let lineType: SupplementLineType
    let lines: [LineCoordinates]

    static var fileURL: URL {
        return Bundle.main.url(forResource: "bikeways", withExtension: "kml")!
    }
}

func bikewayToPolylines(_ bikeway: Bikeway) -> [SupplementPolyline] {
    return bikeway.lines.map { lineStrings in
        let coordinates = lineStrings |> lineStringsToCLLocationCoordinate2D
        let new = SupplementPolyline(coordinates: coordinates, count: coordinates.count)
        new.lineType = bikeway.lineType
        return new
    }
}

// MARK: - Polyline

class SupplementPolyline: MKPolyline {
    var lineType: SupplementLineType!
}

func loadBikeways() throws -> [MKPolyline] {
    return try Bikeway.fileURL
        |>  getXMLDocument
        >>> getPlacemarkElements
        >>> compactMap(getBikeway)
        >>> map(bikewayToPolylines)
        >>> flattenArrays
}

func makePolylineRenderer(for supplementPolyline: SupplementPolyline) -> MKPolylineRenderer {
    let renderer = MKPolylineRenderer(polyline: supplementPolyline)
    renderer.strokeColor = Styles.Color.secondary
    renderer.lineWidth = 3.0

    if let lineType = supplementPolyline.lineType,
        case .bikeRouteDashed = lineType {
        renderer.lineDashPattern =  [5, 5]
    }

    return renderer
}
