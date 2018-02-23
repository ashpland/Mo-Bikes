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
        
        stationManager = StationManager()
        
        let storyboard = UIStoryboard(name: "MapView",
                                      bundle: Bundle.main)
        mapViewController = storyboard.instantiateInitialViewController() as! MapViewController
        
        UIApplication.shared.keyWindow?.rootViewController = mapViewController
        
        // Test and Load the View at the Same Time!
        XCTAssertNotNil(mapViewController.view)
        
        mapView = mapViewController.mapView
        
        // set location and zoom
        
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
        
        let testStation = generateStation("Test Station")
        
        mapViewModel.display([testStation], in: mapView)
        
        if let firstAnnotation = mapView.annotations.first {
            let testStationCoordinate = CLLocationCoordinate2D(latitude: testStation.coordinate.lat, longitude: testStation.coordinate.lon)
            XCTAssertEqual(firstAnnotation.coordinate, testStationCoordinate, "Annotation should have same coordinates as Station")
        }
        
    }
    
    func testDisplayMarker() {
        
        mapView.region
        
        print(mapView.region.center)
        print(mapView.region.span)
        
        // stations coordinates needs to be in visible bounds of mapview. Can you set mapview to whole map?
        
        let testStation = generateStation("Test Station")
        
        mapViewModel.display([testStation], in: mapView)
        
        let annotationContainerView = mapView.subviews[0].subviews[2]
        
        XCTAssertTrue(annotationContainerView.subviews.count > 0)
    }
}





