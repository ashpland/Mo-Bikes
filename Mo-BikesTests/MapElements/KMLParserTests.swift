//
//  KMLParserTests.swift
//  Mo-BikesTests
//
//  Created by Andrew on 2018-10-20.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import XCTest
import AEXML
@testable import Mo_Bikes

class KMLParserTests: XCTestCase {

    var xmlDoc: AEXMLDocument!

    override func setUp() {
        xmlDoc = makeXMLDoc()
    }

    func testGetXMLDocumentThrows() {
        XCTAssertThrowsError(try getXMLDocument(xmlurl: URL(fileURLWithPath: "fail")))
    }

    func testGetPlacemarkElements() {
        var folder = xmlDoc.root["Document"]["Folder"]
        folder &> addChild(makePointPlacemark())
        let elements = try? xmlDoc |> getPlacemarkElements
        XCTAssertNotNil(elements)
    }

    func testGetPlacemarkElementsThrows() {
        XCTAssertThrowsError(try xmlDoc |> getPlacemarkElements)
    }

    func testGetPointCoordinateString() {
        XCTAssertNotNil(makePointPlacemark() |> getPointCoordinateString)
    }

    func testGetBikeway() {
        if let bikeway = makeBikewayPlacemark() |> getBikeway {
            XCTAssertFalse(bikeway.lines.isEmpty)
        }
    }

    func testGetBikewayFail() {
        XCTAssertNil(AEXMLElement(name: "Not a bikeway") |> getBikeway)
    }

    func testGetLineCoordinatesString() {
        var element = AEXMLElement(name: "element")
        element &> addChild("coordinates", value: "-123.166270453668,49.2710157338192,0.0 -123.166270454964,49.2710157104298,0.0 -123.16630123224,49.2701228944955,0.0 -123.166315536304,49.2696909217319,0.0 -123.166331107411,49.2692315180453,0.0")

        XCTAssertEqual(getLineCoordinatesString(element)?.first, "-123.166270453668,49.2710157338192,0.0")
    }
}
