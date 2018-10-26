//
//  main.swift
//  Mo-Bikes
//
//  Created by Andrew on 2018-10-19.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import UIKit

let isRunningTests = NSClassFromString("XCTestCase") != nil
let appDelegateClass = isRunningTests ? nil : NSStringFromClass(AppDelegate.self)
let argv = UnsafeMutableRawPointer(CommandLine.unsafeArgv).bindMemory(to: UnsafeMutablePointer<Int8>?.self, capacity: Int(CommandLine.argc))
UIApplicationMain(CommandLine.argc, argv, nil, appDelegateClass)
