//
//  Generators.swift
//  Mo-BikesTests
//
//  Created by Andrew on 2018-02-22.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import Foundation
@testable import Mo_Bikes


func generateLatLon() -> (lat: Double, lon: Double) {
    let lat = Double(arc4random_uniform(90*1000000)) / 1000000
    let lon = Double(Int(arc4random_uniform(360*1000000)) - 180*1000000) / 1000000
    return (lat, lon)
}

func generateSlots() -> (total: Int, bikes: Int, free: Int) {
    let uTotal = arc4random_uniform(99) + 1
    let total = Int(uTotal)
    let bikes = Int(arc4random_uniform(uTotal))
    let slots = total - bikes
    
    return (total, bikes, slots)
}

func generateStation(_ name: String) -> Station {
    let slots = generateSlots()
    return Station(name: name,
                   coordinate: generateLatLon(),
                   totalSlots: slots.total,
                   freeSlots: slots.free,
                   availableBikes: slots.bikes,
                   operative: true)
}
