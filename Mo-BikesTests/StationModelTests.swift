//
//  StationModelTests.swift
//  Mo-BikesTests
//
//  Created by Andrew on 2018-10-07.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxBlocking
@testable import Mo_Bikes

class StationDataTests: XCTestCase {

    func testStationDataDecodable() {
        let stationData = generateStationData("Test Station")
        let stationJSON = generateStationJSON(stationData)

        let newStationData = StationData.decode(from: stationJSON)

        guard let stations = newStationData,
            let station = stations.first else {
                XCTFail("Couldn't get decoded station.")
                return
        }

        XCTAssertEqual(stationData.name, station.name)
        XCTAssertEqual(stationData.coordinates, station.coordinates)
        XCTAssertEqual(stationData.totalDocks, station.totalDocks)
        XCTAssertEqual(stationData.availableDocks, station.availableDocks)
        XCTAssertEqual(stationData.availableBikes, station.availableBikes)
        XCTAssertEqual(stationData.operative, station.operative)
    }

    func testStationDataDecodeFail() {
        let badStationData = "Not JSON".data(using: .utf8)!
        let failedDecode = StationData.decode(from: badStationData)
        XCTAssertNil(failedDecode)
    }
}

class StationTests: XCTestCase {

    let stationName = "Test Station"
    var stationData0: StationData!
    var stationData1: StationData!
    var testStation: Station!
    var disposeBag: DisposeBag = DisposeBag()

        override func setUp() {
            super.setUp()
            stationData0 = generateStationData(stationName)
            stationData1 = generateStationData(stationName)
            testStation = Station(stationData0)
        }

        override func tearDown() {
            disposeBag = DisposeBag()
            super.tearDown()
        }

    func testStationInit() {
        XCTAssertEqual(testStation.name, stationName)
    }

    func testStationCoordinates() {
        let coordinate = testStation.coordinate
        let coordinatesString = "\(coordinate.latitude), \(coordinate.longitude)"
        XCTAssertEqual(stationData0.coordinates, coordinatesString)
    }

    func testStationAvailableBikesDriver() {
        let expect = expectation(description: #function)
        let results = try? testStation.availableBikesDriver
            .asObservable()
            .take(2)
            .do(onNext: { _ in self.testStation.stationData = self.stationData1 },
                onCompleted: { expect.fulfill() })
            .toBlocking()
            .toArray()

        wait(for: [expect], timeout: 1.0)
        XCTAssertEqual(results, [self.stationData0.availableBikes, self.stationData1.availableBikes])
    }

    func testStationAvailableDocksDriver() {
        let expect = expectation(description: #function)
        let results = try? testStation.availableDocksDriver
            .asObservable()
            .take(2)
            .do(onNext: { _ in self.testStation.stationData = self.stationData1 },
                onCompleted: { expect.fulfill() })
            .toBlocking()
            .toArray()

        wait(for: [expect], timeout: 1.0)
        XCTAssertEqual(results, [self.stationData0.availableDocks, self.stationData1.availableDocks])
    }

}
