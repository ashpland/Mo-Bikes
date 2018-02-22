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
}

