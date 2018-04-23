//
//  StationManagerTests.swift
//  Mo-BikesTests
//
//  Created by Andrew on 2018-02-22.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
@testable import Mo_Bikes

class StationManagerTests: XCTestCase {
    
    var stationManager: StationManager!
    
    override func setUp() {
        super.setUp()
        stationManager = StationManager()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSameStationsEqual() {
        let testStation0 = generateStation("Test Station")
        let testStation1 = generateStation("Test Station")
        XCTAssertEqual(testStation0, testStation1)
    }
    
    func testDifferentStationsNotEqual() {
        let testStation0 = generateStation("Test Station 0")
        let testStation1 = generateStation("Test Station 1")
        XCTAssertNotEqual(testStation0, testStation1)
    }
    
    func testAddStation() {
        let testStation = generateStation("Test Station")
        stationManager.update([testStation])
        if let resultStation = stationManager.stations.value.first {
            XCTAssertEqual(testStation, resultStation)
        }
    }
    
    func testUpdateStation() {
        let originalStation = generateStation("Test Station")
        let newValue = originalStation.availableBikes.value + 1
        let updatedStation = originalStation
        updatedStation.availableBikes.accept(newValue)
        _ = originalStation.update(from: updatedStation)
        XCTAssertEqual(originalStation.availableBikes.value, newValue)
    }

    func testSyncStations() {
        var testStations = [Station]()

        for i in 0...2 {
            testStations.append(generateStation("Station \(i)"))
        }

        let initialStations = Array(testStations[...1])
        let updatedStations = Array(testStations[1...])

        stationManager.update(initialStations)
        stationManager.update(updatedStations)
        
        XCTAssertFalse(testStations[0].operative.value,
                       "Station 0 should set operative to false on removal")

        let stations = stationManager.stations.value
        
        XCTAssertFalse(stations.contains(testStations[0]) , "Station 0 should be removed")
        XCTAssertTrue(stations.contains(testStations[2]) , "Station 2 should be added")
        XCTAssert(stations.containsSameElements(as: updatedStations), "Updating should make stations array same as updatedStations")
    }
}

