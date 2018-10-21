//
//  MiscTests.swift
//  Mo-BikesTests
//
//  Created by Andrew on 2018-10-19.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import XCTest
@testable import Mo_Bikes

enum TestError: String, RawErrorEnum {
    case test
}

class ErrorsTests: XCTestCase {
    func testDescription() {
        XCTAssertEqual(TestError.test.errorDescription,
                       "test")
    }

    func testDoCatchPrint() {
        let throwFunc: () throws -> Void = {
            throw TestError.test
        }
        if let error = doCatchPrint(throwFunc) {
            XCTAssertEqual(error.localizedDescription,
                           TestError.test.localizedDescription)
        }
    }
}

class StylesTests: XCTestCase {
    func testSecondaryTintColor() {
        let isOn  = secondaryTintColor(true)
        let isOff = secondaryTintColor(false)
        XCTAssertEqual(isOn, Styles.Color.secondary)
        XCTAssertEqual(isOff, Styles.Color.inactive)
    }

    func testMarkerColor() {
        let normal = markerColor(Styles.lowAvailable + 1)
        let low    = markerColor(Styles.lowAvailable)
        XCTAssertEqual(normal, Styles.Color.marker.normal)
        XCTAssertEqual(low, Styles.Color.marker.low)
    }
}
