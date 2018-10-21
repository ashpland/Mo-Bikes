//
//  KMLParserTests.swift
//  Mo-BikesTests
//
//  Created by Andrew on 2018-10-20.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import XCTest
import AEXML
@testable import Mo_Bikes

class KMLParserTests: XCTestCase {
    
    var xmlDoc: AEXMLDocument!
    
    override func setUp() {
        xmlDoc = makeXMLDoc()
    }
    
    func testGetXMLDocument() {
        // TODO: Implement with Global
    }
    
    func testGetPlacemarkElements() {
        xmlDoc |> addChild("Placemark")
        
    }
    
    func testGetPlacemarkElementsThrows() {
        XCTAssertThrowsError(try xmlDoc |> getPlacemarkElements)
    }

    
    func testGetPointCoordinateString() {
        
    }
    
    func testGetBikeway() {
        
    }
    
    func testGetLineCoordinatesString() {
        
    }
}
