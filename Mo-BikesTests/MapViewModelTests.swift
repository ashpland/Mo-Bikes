//
//  MapViewModelTests.swift
//  Mo-BikesTests
//
//  Created by Andrew on 2018-10-07.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import XCTest
import MapKit
import RxSwift
import RxCocoa
import RxBlocking
@testable import Mo_Bikes

class MapViewModelTests: XCTestCase {

    var mapViewModel: MapViewModel!
    var mockAPI: MockAPI?

    var disposeBag = DisposeBag()

    override func setUp() {
        super.setUp()
        mapViewModel = MapViewModel()
    }

    override func tearDown() {
        disposeBag = DisposeBag()
        mockAPI = nil
        super.tearDown()
    }

    func testAddStation() {
        let stationData = [generateStationData("0")]
        let stations = stationData.map { Station($0) }
        let expect = expectation(description: #function)
        let results = try? mapViewModel.stationsToAddDriver
            .asObservable()
            .take(2)
            .do(onNext: { _ in self.mapViewModel.updateStations(from: stationData) },
                onCompleted: { expect.fulfill() })
            .map { $0.map { $0 as! Station } }
            .toBlocking()
            .toArray()

        wait(for: [expect], timeout: 1.0)

        XCTAssertEqual(results!, [[Station](), stations])
    }

    func testRemoveStation() {
        let stationData0 = generateStationData("0")
        let stationData1 = generateStationData("1")

        let initialStationData = [stationData0, stationData1]
        let updatedStationData = [stationData1]
        let station0 = Station(stationData0)
        mapViewModel.updateStations(from: initialStationData)

        let expect = expectation(description: #function)
        let result = try? mapViewModel.stationsToRemoveSignal
            .asObservable()
            .take(1)
            .do(onCompleted: { expect.fulfill() },
                onSubscribed: { self.mapViewModel.updateStations(from: updatedStationData) })
            .map { $0 as! Station }
            .toBlocking()
            .first()

        wait(for: [expect], timeout: 1.0)
        XCTAssertEqual(result, station0)
    }

    func testUpdateStation() {
        let stationData0 = generateStationData("Test Station")
        let stationData1 = generateStationData("Test Station")

        mapViewModel.updateStations(from: [stationData0])

        let expect = expectation(description: #function)
        let results = try? mapViewModel.stationsToAddDriver
            .asObservable()
            .take(2)
            .do(onNext: { _ in self.mapViewModel.updateStations(from: [stationData0]) })
            .map { $0.map { $0 as! Station } }
            .toBlocking()
            .toArray()

        guard let station = results?.first?.first else {
            XCTFail()
            return
        }

        let resultData0 = station.stationData
        mapViewModel.updateStations(from: [stationData1])
        let resultData1 = station.stationData
        expect.fulfill()

        wait(for: [expect], timeout: 1.0)
        XCTAssertEqual(stationData0, resultData0)
        XCTAssertEqual(stationData1, resultData1)
    }

    func testGetStationData() {
        mockAPI = MockAPI()

        let newStationData = try? mapViewModel
            .getStationData()
            .toBlocking()
            .single()

        if let newStationData = newStationData,
            let first = newStationData.first {
            XCTAssertEqual(first.name, "0001 10th & Cambie")
        } else {
            XCTFail()
        }
    }
}
