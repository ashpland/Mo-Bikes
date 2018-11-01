//
//  UIViewFunctionsTests.swift
//  Mo-BikesTests
//
//  Created by Andrew on 2018-10-31.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import XCTest
import UIKit
@testable import Mo_Bikes

class UIViewFunctionsTests: XCTestCase {
    var testView: UIView!

    override func setUp() {
        testView = UIView()
    }

    func testRoundCorners() {
        let testRadius: CGFloat = 1.0
        testView &> roundCorners(testRadius)
        XCTAssertEqual(testView.layer.cornerRadius, testRadius)
    }

    func testAddBorder() {
        let testColor = UIColor.black.cgColor
        let testWidth: CGFloat = 1.0
        testView &> addBorder((testColor, testWidth))
        XCTAssertEqual(testView.layer.borderColor, testColor)
        XCTAssertEqual(testView.layer.borderWidth, testWidth)
    }

    func testCurrentRotation() {
        XCTAssertEqual(currentRotation(of: testView), 0)
    }

    func testSetRotate() {
        let testRotation: CGFloat = 1.0
        testView &> setRotate(testRotation)
        XCTAssertEqual(currentRotation(of: testView), testRotation)
    }

    func testInRadians() {
        XCTAssertEqual(0   |> inRadians, 0)
        XCTAssertEqual(90  |> inRadians, 1.57079, accuracy: 0.00001)
        XCTAssertEqual(180 |> inRadians, 3.14159, accuracy: 0.00001)
        XCTAssertEqual(270 |> inRadians, 4.71238, accuracy: 0.00001)
    }

}
