//
//  MapViewModelTests.swift
//  Mo-BikesTests
//
//  Created by Andrew on 2018-02-22.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import RxBlocking
import MapKit
@testable import Mo_Bikes

class MapViewModelTests: XCTestCase {
    
    var stationManager: StationManager!
    var mapViewModel: MapViewModel!
    var disposeBag = DisposeBag()
    
    override func setUp() {
        super.setUp()
        
        stationManager = StationManager()
        mapViewModel = MapViewModel(stationManager)
    }
    
    override func tearDown() {
        disposeBag = DisposeBag()
        super.tearDown()
    }
    
    func testCreateStationAnnotation() {
        let expect = expectation(description: "Recieve first stationAnnotation")
        let testStation = generateStation("Test Station")
        
        mapViewModel.stationAnnotations
            .subscribe(onNext: { stations in
                XCTAssertNotNil(stations.first)
                expect.fulfill()
            })
            .disposed(by: disposeBag)
        
        stationManager.update([testStation])
        
        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testSetInoperative() {}
    
    func testChangeBikeOrDockState() {}
    func testChangeNumAvailable() {}
    func testIsSelected() {}
    func testIsDeselected() {}
    
}
