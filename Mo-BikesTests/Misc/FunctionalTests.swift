//
//  FunctionalTests.swift
//  Mo-BikesTests
//
//  Created by Andrew on 2018-10-19.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import XCTest
@testable import Mo_Bikes

class FunctionalTests: XCTestCase {

    // MARK: - Function application and composition

    func testForwardApplication() {
        XCTAssertEqual(1 |> aToA, 2)
    }

    func testForwardComposition() {
        XCTAssertEqual(1 |> aToB >>> bToC, ["1"])
    }

    func testSingleTypeComposition() {
        XCTAssertEqual(1 |> aToA <> aToA, 3)
    }

    // MARK: - Function Manipulation

    func testCurry() {
        let a = 2, b = 1
        let curried = curry(aAndBToC)
        XCTAssertEqual(aAndBToC(a: a, b: b), curried(a)(b))
    }

    func testFlip() {
        let a = 2, b = 1
        let flipped = flip(curry(aAndBToC))
        XCTAssertEqual(aAndBToC(a: a, b: b), flipped(b)(a))
    }

    func testZurry() {
        let zurried = zurry(voidToA)
        XCTAssertEqual(voidToA(), zurried)
    }

    // MARK: - Mapping

    func testMap() {
        XCTAssertEqual([1] |> map(aToA), [2])
    }

    func testCompactMap() {
        XCTAssertEqual([1, 2] |> compactMap(aToAOptional), [3])
    }

    func testFlattenArrays() {
        XCTAssertEqual([[1], [2]] |> flattenArrays, [1, 2])
    }

    // MARK: - Setters

    func testSetValueTo() {
        var testObject = TestObject()
        testObject &> set(\.value, to: 1)
        XCTAssertEqual(testObject.value, 1)
    }

    func testSetValueOn() {
        let testObject = TestObject()
        1 |> set(\.value, on: testObject)
        XCTAssertEqual(testObject.value, 1)
    }

    // MARK: - Inout

    func testInOutForwardApplication() {
        var testObject = TestObject()
        testObject &> aToAInOut
        XCTAssertEqual(testObject.value, 1)
    }

    func testInOutOptionalForwardApplication() {
        let testObject: TestObject! = TestObject()
        testObject &> aToAInOut
        XCTAssertEqual(testObject.value, 1)
    }

    func testInOutForwardApplicationReturn() {
        var testObject = TestObject()
        let result = testObject &> aInOutToB
        XCTAssertEqual(result, 0)
    }

    func testInOutSingleTypeComposition() {
        var testObject = TestObject()
        testObject &> aToAInOut <> aToAInOut
        XCTAssertEqual(testObject.value, 2)
    }

    func testInOutForwardComposition() {
        let testObject1 = 0 |> TestObject.init >>> aToAInOutReturns
        XCTAssertEqual(testObject1.value, 1)

        var testObject2 = TestObject()
        testObject2 &> aToAInOutReturns >>> aToAInOutReturns
        XCTAssertEqual(testObject2.value, 2)
    }

    func testInOutMap() {
        let testObject = TestObject()
        [testObject] |> map(aToAInOutReturns)
        XCTAssertEqual(testObject.value, 1)
    }

    // MARK: - Overloads for throwing functions

    func testForwardApplicationThrows() {
        XCTAssertThrowsError(try 1 |> aToAThrows)
    }

    func testForwardCompositionThrows() {
        XCTAssertThrowsError(try 1 |> aToAThrows >>> aToA)
        XCTAssertThrowsError(try 1 |> aToA >>> aToAThrows)
        XCTAssertThrowsError(try 1 |> aToAThrows >>> aToAThrows)
    }

    func testInOutForwardApplicationThrows() {
        var testObject = TestObject()
        XCTAssertThrowsError(try testObject &> aToAInOutThrows)
    }

    func testInOutSingleTypeCompositionThrows() {
        var testObject = TestObject()
        XCTAssertThrowsError(try testObject &> aToAInOutThrows <> aToAInOut)
        XCTAssertThrowsError(try testObject &> aToAInOut <> aToAInOutThrows)
        XCTAssertThrowsError(try testObject &> aToAInOutThrows <> aToAInOutThrows)
    }
}

// MARK: -

class TestObject {
    var value: Int

    init(value: Int = 0) {
        self.value = value
    }
}

// MARK: - Test Functions

func aToA(_ a: Int) -> Int {
    return a + 1
}

func aToAOptional(_ a: Int) -> Int? {
    if a % 2 == 0 {
        return aToA(a)
    } else {
        return nil
    }
}

func aToAThrows(_ a: Int) throws -> Int {
    throw TestError.test
}

func aToAInOut(_ a: inout TestObject) {
    a.value += 1
}

func aToAInOutReturns(_ a: inout TestObject) -> TestObject {
    a.value += 1
    return a
}

func aToAInOutThrows(_ a: inout TestObject) throws {
    throw TestError.test
}

func aToB(_ a: Int) -> String {
    return String(a)
}

func aInOutToB(_ a: inout TestObject) -> Int {
    return a.value
}

func bToC(_ b: String) -> [String] {
    return [b]
}

func aAndBToC(a: Int, b: Int) -> Int {
    return a - b
}

func voidToA() -> Int {
    return 1
}
