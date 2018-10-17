//
//  KMLParser.swift
//  Mo-Bikes
//
//  Created by Andrew on 2018-10-16.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import AEXML

// TODO: use these once functions compose with throw
enum XMLError: Error {
    case conversionFailed
    case noPlacemarks
}

typealias PointCoordinate = String
typealias LineCoordinates = [PointCoordinate]

func getXMLDocument(xmlurl: URL) -> AEXMLDocument? {
    if let xmlData = try? Data(contentsOf: xmlurl),
        let xmlDoc = try? AEXMLDocument(xml: xmlData) {
        return xmlDoc
    } else {
        return nil
    }
}

func getPlacemarkElements(_ xmlDoc: AEXMLDocument?) -> [AEXMLElement] {
    if let xmlDoc = xmlDoc,
        let elements = xmlDoc.root["Document"]["Folder"]["Placemark"].all {
        return elements
    } else {
       return [AEXMLElement]()
    }
}

func getPointCoordinateString(_ element: AEXMLElement) -> PointCoordinate? {
    return element["Point"]["coordinates"].value
}

fileprivate func makeBikeway(of lineType: SupplementLineType) -> ([LineCoordinates]) -> Bikeway {
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
