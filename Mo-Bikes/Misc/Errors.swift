//
//  Errors.swift
//  Mo-Bikes
//
//  Created by Andrew on 2018-10-19.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import Foundation

protocol RawErrorEnum: LocalizedError {
    var rawValue: String { get }
}

extension RawErrorEnum {
    var errorDescription: String? {
        return self.rawValue
    }
}

enum MapError: String, RawErrorEnum {
    case noLocation = "Unable to retrieve location"
}

enum JSONError: String, RawErrorEnum {
    case decoding = "JSON Decoding Error"
}

func doCatchPrint(_ function: (() throws -> Void)) {
    do {
        try function()
    } catch {
        debugPrint("Error: \(error.localizedDescription)")
    }
}
