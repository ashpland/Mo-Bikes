//
//  CoordinatesTests.swift
//  Mo-BikesTests
//
//  Created by Andrew on 2018-10-19.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import XCTest
import MapKit
@testable import Mo_Bikes

let kmlString: PointCoordinate = "-123.121817,49.274566,0.0"
let jsonString: PointCoordinate = "49.274566,  -123.121817"
let clCoordinate = CLLocationCoordinate2D(latitude: 49.274566, longitude: -123.121817)

class CoordinatesTests: XCTestCase {
    func testKMLString() {
        XCTAssertEqual(stringToCLLocationCoordinate2D(kmlString),
                       clCoordinate)
    }
    
    func testJSONString() {
        XCTAssertEqual(stringToCLLocationCoordinate2D(jsonString),
                       clCoordinate)
    }
    
    func testInvalidString() {
        XCTAssertEqual(stringToCLLocationCoordinate2D("hey"),
                       kCLLocationCoordinate2DInvalid)
    }
    
    func testLineStrings() {
        XCTAssertEqual(lineStringsToCLLocationCoordinate2D([jsonString]),
                       [clCoordinate])
    }
}
