//
//  BikewayTests.swift
//  Mo-BikesTests
//
//  Created by Andrew on 2018-10-20.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import XCTest
import MapKit
@testable import Mo_Bikes

class BikewayTests: XCTestCase {
    let pointCoordinate = "-123.121817,49.274566,0.0"
    var clCoordinate: CLLocationCoordinate2D {
        return pointCoordinate |> stringToCLLocationCoordinate2D
    }

    func testExtractLineType() {
        let localString = "Local Street<br>"
        let protectedString = "Protected Bike Lanes<br>"
        let paintedString = "Painted Lanes<br>"
        let sharedString = "Shared Lanes<br>"
        let emptyString = ""

        XCTAssertEqual(extractLineType(from: localString),     .bikeRouteSolid)
        XCTAssertEqual(extractLineType(from: protectedString), .bikeRouteSolid)
        XCTAssertEqual(extractLineType(from: paintedString),   .bikeRouteDashed)
        XCTAssertEqual(extractLineType(from: sharedString),     nil)
        XCTAssertEqual(extractLineType(from: emptyString),      nil)
    }
    
    func testBikewayToPolylines() {
        let testBikeway = Bikeway(lineType: .bikeRouteSolid, lines: [[pointCoordinate]])
        let polylines = testBikeway |> bikewayToPolylines
        if let points = polylines.first?.points() {
            XCTAssertEqual(points[0].coordinate.latitude,  clCoordinate.latitude,  accuracy: 0.0000001)
            XCTAssertEqual(points[0].coordinate.longitude, clCoordinate.longitude, accuracy: 0.0000001)
        }
    }
    
    func testMakePolylineRenderer() {
        XCTAssertNil(.bikeRouteSolid |> dashPattern)
        XCTAssertEqual(.bikeRouteDashed |> dashPattern, [5, 5])
    }
    
    func dashPattern(_ lineType: SupplementLineType) -> [NSNumber]? {
        let testBikeway = Bikeway(lineType: lineType, lines: [[pointCoordinate]])
        let polylines = testBikeway |> bikewayToPolylines
        if let firstPolyline = polylines.first {
            let renderer = firstPolyline |> makePolylineRenderer
            return renderer.lineDashPattern
        } else {
            XCTFail()
            return nil
        }
    }
    
//    func testLoadBikeways() {
//        if let bikeways = try? loadBikeways() {
//            XCTAssertNotNil(bikeways.first)
//        } else {
//            XCTFail("Could not load bikeways.")
//        }
//    }
}

