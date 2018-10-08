//
//  StationViewModelTests.swift
//  Mo-BikesTests
//
//  Created by Andrew on 2018-10-07.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
@testable import Mo_Bikes

class StationViewModelTests: XCTestCase {
    let stationName = "Test Station"
    let level = (low: Styles.lowAvailable, normal: Styles.lowAvailable + 1)
    var stationData1: StationData!
    var stationData2: StationData!
    var testStation: Station!
    var testStationViewModel: StationViewModel!
    var bikesOrDocksRelay: BehaviorRelay<BikesOrDocksState>!
    var disposeBag: DisposeBag = DisposeBag()

    override func setUp() {
        super.setUp()
        stationData1 = generateStationData(stationName)
        let replacementData1  = StationData(name: stationData1.name,
                                            coordinates: stationData1.coordinates,
                                            totalDocks: 0,
                                            availableDocks: 0,
                                            availableBikes: level.low,
                                            operative: stationData1.operative)

        let replacementData2  = StationData(name: stationData1.name,
                                            coordinates: stationData1.coordinates,
                                            totalDocks: 0,
                                            availableDocks: 0,
                                            availableBikes: level.normal,
                                            operative: stationData1.operative)

        stationData1 = replacementData1
        stationData2 = replacementData2
        testStation = Station(stationData1)
        bikesOrDocksRelay = BehaviorRelay(value: .bikes)
        testStationViewModel = StationViewModel(station: testStation,
                                                bikesOrDocksState: bikesOrDocksRelay.asDriver())

    }

    override func tearDown() {
        disposeBag = DisposeBag()
        super.tearDown()
    }

    func testStationViewModelMarkerTintColor() {
        let expect = expectation(description: #function)
        var results = [UIColor]()

        testStationViewModel.markerTintColor
            .asObservable()
            .take(2)
            .removeNils()
            .subscribe({ event in
                switch event {
                case .next(let color):
                    results.append(color)
                    self.testStation.stationData = self.stationData2
                case .error(let error):
                    XCTFail(error.localizedDescription)
                case .completed:
                    expect.fulfill()
                }
            })
            .disposed(by: disposeBag)

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            } else {
                XCTAssertEqual(results, [Styles.markerColor.low, Styles.markerColor.normal])
            }
        }

    }

    func testStationViewModelGlyphText() {
        let expect = expectation(description: #function)
        var results = [String?]()

        testStationViewModel.glyphText
            .asObservable()
            .take(3)
            .subscribe({ event in
                switch event {
                case .next(let text):
                    results.append(text)
                    if text == nil {
                        self.testStationViewModel.stationIsSelected.accept(true)
                    } else {
                        self.bikesOrDocksRelay.accept(.docks)
                    }
                case .error(let error):
                    XCTFail(error.localizedDescription)
                case .completed:
                    expect.fulfill()
                }
            })
            .disposed(by: disposeBag)

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            } else {
                XCTAssertEqual(results, [nil,
                                         String(self.stationData1.availableBikes),
                                         String(self.stationData1.availableDocks)])
            }
        }
    }

    func testStationViewModelGlyphImage() {
        let expect = expectation(description: #function)
        var results = [UIImage?]()

        testStationViewModel.glyphImage
            .asObservable()
            .take(3)
            .subscribe({ event in
                switch event {
                case .next(let image):
                    results.append(image)
                    if self.bikesOrDocksRelay.value == .bikes {
                        self.bikesOrDocksRelay.accept(.docks)
                    } else {
                        self.testStationViewModel.stationIsSelected.accept(true)
                    }
                case .error(let error):
                    XCTFail(error.localizedDescription)
                case .completed:
                    expect.fulfill()
                }
            })
            .disposed(by: disposeBag)

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            } else {
                XCTAssertEqual(results, [Styles.glyphs.bikes,
                                         Styles.glyphs.docks,
                                         nil])
            }
        }
    }

}
