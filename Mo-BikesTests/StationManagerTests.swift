//
//  StationManagerTests.swift
//  Mo-BikesTests
//
//  Created by Andrew on 2018-02-22.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import XCTest
import RxSwift
@testable import Mo_Bikes

class StationManagerTests: XCTestCase {
    
    var stationManager: StationManager!
    let disposeBag = DisposeBag()
    
    override func setUp() {
        super.setUp()
        
        stationManager = StationManager()
        
    }
    
    override func tearDown() {
        
        stationManager.stations.subscribe(onNext: {
            stations in
            for station in stations {
                station.operative.onNext(false)
            }
        }).disposed(by: disposeBag)
        
        
        super.tearDown()
    }
    
    func testAddStation() {
        
        let expectStation = expectation(description: "Station should appear in stations array")
        
        let testStation = generateStation("Test Station")
        
        stationManager.stations.subscribe(onNext: {
            stations in
            
            switch stations.count {
            case 0:
                return
            default:
                if let firstStation = stations.first {
                    XCTAssertEqual(testStation, firstStation, "Stations should be equal")
                    expectStation.fulfill()
                }
            }
        }).disposed(by: disposeBag)
        
        stationManager.update([testStation])
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testSyncStations() {
        let expectStations = expectation(description: "Station should appear in stations array")
        
        var testStations = [Station]()
        
        for i in 1...3 {
            testStations.append(generateStation("Station \(i)"))
        }
        
        let initialStations = Array(testStations[...1])
        let updatedStations = Array(testStations[1...])
        
        stationManager.stations.subscribe(onNext: {
            stations in
            
            guard stations.count != 0 && !stations.containsSameElements(as: initialStations) else { return }
            
            XCTAssertFalse(stations.contains(testStations[0]) , "Station 0 should be removed")
            XCTAssertTrue(stations.contains(testStations[2]) , "Station 2 should be added")
            XCTAssert(stations.containsSameElements(as: updatedStations), "Updating should make stations array same as updatedStations")
            expectStations.fulfill()
            
        }).disposed(by: disposeBag)
        
        stationManager.update(initialStations)
        stationManager.update(updatedStations)
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
}

