//
//  StationModelTests.swift
//  Mo-BikesTests
//
//  Created by Andrew on 2018-10-19.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import XCTest
@testable import Mo_Bikes

class StationModelTests: XCTestCase {

    let testStationData1 = generateStationData("Test Station 1")
    let testStationData2 = generateStationData("Test Station 2")
    
    func testDecodeStationData() {
        let testJSON = generateStationJSON(testStationData1)
        
        if let result = try? StationData.decode(from: testJSON),
            let first = result.first {
            XCTAssertEqual(first, testStationData1)
        }
    }
    
    func testDecodeStationDataThrows() {
        let badJSON = "hey".data(using: .utf8)!
        XCTAssertThrowsError(try StationData.decode(from: badJSON))
    }
    
    func testStationIsEqual() {
        XCTAssertEqual(Station(testStationData1),
                       Station(testStationData1))
    }
    
    func testStationNotEqual() {
        XCTAssertNotEqual(Station(testStationData1),
                          Station(testStationData2))
    }
    
    func testStationName() {
        XCTAssertEqual(Station(testStationData1).name,
                       testStationData1.name)
    }
    
}
