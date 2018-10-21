//
//  SupplementMarkerTests.swift
//  Mo-BikesTests
//
//  Created by Andrew on 2018-10-20.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import XCTest
import MapKit
@testable import Mo_Bikes

class SupplementMarkerTests: XCTestCase {
    let pointCoordinate = "-123.121817,49.274566,0.0"
    var clCoordinate: CLLocationCoordinate2D {
        return pointCoordinate |> stringToCLLocationCoordinate2D
    }
    
    func testStringToAnnotation() {
        let annotation = pointCoordinate |> stringToAnnotation(of: .fountain)
        XCTAssertEqual(annotation.coordinate, clCoordinate)
    }
    
    func testJustAnnotations() {
        let annotations = [
            pointCoordinate |> stringToAnnotation(of: .fountain),
            pointCoordinate |> stringToAnnotation(of: .washroom)
        ]
        
        let justFountains = annotations |> compactMap(justAnnotations(of: .fountain))
        
        XCTAssert(justFountains.count == 1)
        XCTAssertEqual(justFountains.first!.pointType, .fountain)
    }
    
    func testLoadSupplementAnnotations() {
        for pointType in SupplementPointType.allCases {
            if let annotations = try? loadSupplementAnnotations(of: pointType),
                let first = annotations.first as? SupplementAnnotation {
                XCTAssertEqual(first.pointType, pointType)
            } else {
                XCTFail("Could not load \(pointType.rawValue).")
            }
        }
    }
    
    func testConfigureMarker() {
        let annotation = pointCoordinate |> stringToAnnotation(of: .fountain)
        var marker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "ID")
        XCTAssertTrue(marker.isEnabled)
        marker &|> configureMarker(for: annotation)
        XCTAssertFalse(marker.isEnabled)
        XCTAssert(imagesAreSame(lhs: marker.glyphImage, rhs: Styles.glyphImage.fountain))
    }
    
    func testPointGlyphImage() {
        XCTAssertEqual(SupplementPointType.washroom.glyphImage, Styles.glyphImage.washroom)
    }
    
}
