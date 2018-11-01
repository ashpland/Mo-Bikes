//
//  StationTests.swift
//  Mo-BikesTests
//
//  Created by Andrew on 2018-10-19.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import XCTest
@testable import Mo_Bikes

class StationModelTests: XCTestCase {

    let testStationData1 = generateStationData(named: "Test Station 1")
    let testStationData2 = generateStationData(named: "Test Station 2")

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

class StationViewTests: XCTestCase {

    let stationNormal = Station(generateStationData(named: "Normal", (bikes: 9, free: 1)))
    let stationLow =    Station(generateStationData(named: "Normal", (bikes: 1, free: 9)))

    func makeStationView(from station: Station) -> StationView {
        let view = StationView(annotation: station, reuseIdentifier: "ID")
        view.stationData = station.stationData
        view.bikesOrDocks = .bikes
        return view
    }

    func testSetColor() {
        var normalView = makeStationView(from: stationNormal)
        var lowView = makeStationView(from: stationLow)

        normalView &> setStationViewColor
        lowView &> setStationViewColor

        XCTAssertEqual(normalView.markerTintColor, Styles.Color.marker.normal)
        XCTAssertEqual(lowView.markerTintColor, Styles.Color.marker.low)
    }

    func testSetText() {
        var view = makeStationView(from: stationNormal)
        view.isSelected = false
        view &> setStationViewText
        XCTAssertNil(view.glyphText)

        view.isSelected = true
        view &> setStationViewText
        XCTAssertEqual(view.glyphText, String(stationNormal.stationData.availableBikes))
    }

    func testSetImage() {
        var view = makeStationView(from: stationNormal)
        view.isSelected = true
        view &> setStationViewImage
        XCTAssertNil(view.glyphImage)

        view.isSelected = false
        view &> setStationViewImage
        XCTAssert(imagesAreSame(lhs: view.glyphImage, rhs: Styles.glyphImage.bikes))
    }

    func testConfigureStationView() {
        var view = makeStationView(from: stationNormal)
        view.isSelected = true
        view &> configureStationView(.bikes)
        XCTAssertEqual(view.glyphText, String(stationNormal.stationData.availableBikes))
        view &> configureStationView(.docks)
        XCTAssertEqual(view.glyphText, String(stationNormal.stationData.availableDocks))
    }

    func testStationGlyphImage() {
        XCTAssertEqual(BikesOrDocks.docks.glyphImage, Styles.glyphImage.docks)
    }
}
