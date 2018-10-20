//
//  KMLParser.swift
//  Mo-Bikes
//
//  Created by Andrew on 2018-10-16.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import AEXML

typealias PointCoordinate = String
typealias LineCoordinates = [PointCoordinate]

enum KMLError: String, LocalizedError {
    case conversionFailed = "KML conversion failed"
    case noPlacemarks = "No placemarks found in KML file"

    var errorDescription: String? {
        return self.rawValue
    }
}

func getXMLDocument(xmlurl: URL) throws -> AEXMLDocument {
    if let xmlData = try? Data(contentsOf: xmlurl),
        let xmlDoc = try? AEXMLDocument(xml: xmlData) {
        return xmlDoc
    } else {
        throw KMLError.conversionFailed
    }
}

func getPlacemarkElements(_ xmlDoc: AEXMLDocument) throws -> [AEXMLElement] {
    if let elements = xmlDoc.root["Document"]["Folder"]["Placemark"].all {
        return elements
    } else {
       throw KMLError.noPlacemarks
    }
}

func getPointCoordinateString(_ element: AEXMLElement) -> PointCoordinate? {
    return element["Point"]["coordinates"].value
}

private func makeBikeway(of lineType: SupplementLineType) -> ([LineCoordinates]) -> Bikeway {
    return { Bikeway(lineType: lineType, lines: $0) }
}

func getBikeway(_ element: AEXMLElement) -> Bikeway? {
    guard let description = element["description"].value,
        let lineType = extractLineType(from: description),
        let lines = element["MultiGeometry"]["LineString"].all else {
        return nil
    }

    return lines |> compactMap(getLineCoordinatesString) >>> makeBikeway(of: lineType)
}

func getLineCoordinatesString(_ element: AEXMLElement) -> LineCoordinates? {
    guard let coordinatesString = element["coordinates"].value else {
        return nil
    }
    return coordinatesString
        .split(separator: " ")
        .map(PointCoordinate.init)
}
