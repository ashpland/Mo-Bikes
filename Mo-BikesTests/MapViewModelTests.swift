//
//  MapViewModelTests.swift
//  Mo-BikesTests
//
//  Created by Andrew on 2018-02-22.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import XCTest
import RxSwift
import MapKit
@testable import Mo_Bikes

class MapViewModelTests: XCTestCase {
    
    var stationManager: StationManager!
    var mapViewController: MapViewController!
    var mapViewModel: MapViewModel!
    var mapView: MKMapView!
    let disposeBag = DisposeBag()
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        
        stationManager = StationManager()
        
        let storyboard = UIStoryboard(name: "MapView",
                                      bundle: Bundle.main)
        mapViewController = storyboard.instantiateInitialViewController() as! MapViewController
        
        UIApplication.shared.keyWindow?.rootViewController = mapViewController
        
        XCTAssertNotNil(mapViewController.view)
        
        mapView = mapViewController.mapView        
        
        mapViewModel = MapViewModel(for: mapViewController, with: stationManager)
        
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
    
    func testDisplayStation() {
        
        let testStation = generateStation("Test Station", in: mapView.region)
        
        let testAnnotation = testStation.annotation(in: mapView, with: mapViewModel.bikesOrSlots)
        
        mapViewModel.display([testStation], in: mapView)
        
        if let firstAnnotation = mapView.annotations.first as? StationAnnotation {
            XCTAssertEqual(firstAnnotation, testAnnotation, "Adding annotation to mapView with display(_ in:) should produce same annotation")
        }
    }
    
    func testDisplayMarker() {
        let expectMarker = expectation(description: "Marker should display for Station")

        let testStation = generateStation("Test Station", in: mapView.region)
        
        mapViewModel.display([testStation], in: mapView)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            let stationMarkerCount = self.mapView.subviews[0].subviews[2].subviews
                .filter{$0 is StationMarker}
                .count
            XCTAssertTrue(stationMarkerCount == 1)
            expectMarker.fulfill()
        })
        
        waitForExpectations(timeout: 2) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    
    
    
    // Replace this test with UITest
    func testStationValues() {
        
        let expectValue = expectation(description: "Marker should display number of bikes")
        
        let testStation = generateStation("Test Station", in: mapView.region)
        
        mapViewModel.display([testStation], in: mapView)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            let annotationContainerView = self.mapView.subviews[0].subviews[2]
            let markerArray = annotationContainerView.subviews.filter({ (view) -> Bool in
                view is StationMarker
            })
            
            if let firstMarker = markerArray.first as? StationMarker {
                firstMarker.setSelected(true, animated: true)
                firstMarker.currentNumber
                    .takeUntil(firstMarker.unsubscribeNumber)
                    .subscribe(onNext: { firstMarker.glyphText = $0 })
                    .disposed(by: self.disposeBag)

                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    if let firstNumber = firstMarker.glyphText {
                        
                        do {
                            let testNumber = try testStation.availableBikes.value()
                            XCTAssertEqual(firstNumber, String(testNumber))
                            expectValue.fulfill()
                        }
                        catch {
                            XCTAssert(false, "Unable to retrieve available bikes value from testStation")
                        }
                    }
                })
            }
        })
        
        waitForExpectations(timeout: 4) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
        
        
        
        
        
    }
    
    
}





