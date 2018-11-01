//
//  MapViewFunctionsTests.swift
//  Mo-BikesTests
//
//  Created by Andrew on 2018-10-31.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import XCTest
import MapKit
@testable import Mo_Bikes

class MapViewFunctionsTests: XCTestCase {
    var testMapView: MKMapView!

    override func setUp() {
        testMapView = MKMapView()
    }

    func testGetStations() {
        let testStation = generateStationData(named: "testStation") |> Station.init
        testMapView.addAnnotation(testStation)
        XCTAssertEqual(getStations(from: testMapView).first, testStation)
    }

    func testUpdateMapView() {
        let testStations = Array(1...3) |> map( String.init >>> generateStationData >>> Station.init )
        let initial = testStations.dropLast()  |> Array.init
        let updated = testStations.dropFirst() |> Array.init

        testMapView.addAnnotations(initial)

        (current: updated, remove: [testStations[0]])
            |> update(mapView: &testMapView)

        XCTAssert(getStations(from: testMapView).containsSameElements(as: updated))
    }

    func testDisplaySupplementAnnotations() {
        do {
            let fountains = try loadSupplementAnnotations(of: .fountain).compactMap { $0 as? SupplementAnnotation }

            try testMapView &> displaySupplementAnnotations(.fountain, true)
            try testMapView &> displaySupplementAnnotations(.washroom, true)

            let allAnnotations = testMapView.annotations
            let fountainsFromMap = allAnnotations.compactMap(justAnnotations(of: .fountain))
            XCTAssert(fountainsFromMap.containsSameElements(as: fountains))

            try testMapView &> displaySupplementAnnotations(.fountain, false)
            let remainingAnnotations = testMapView.annotations
            XCTAssert(remainingAnnotations.count == allAnnotations.count - fountains.count)
        } catch {
            XCTFail()
        }
    }
}
