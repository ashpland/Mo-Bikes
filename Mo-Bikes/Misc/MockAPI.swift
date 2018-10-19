//
//  MockAPI.swift
//  Mo-Bikes
//
//  Created by Andrew on 2018-02-15.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import OHHTTPStubs
import OHHTTPStubs.NSURLRequest_HTTPBodyTesting

struct MockAPI {
    init() {
        stub(condition: isHost("vancouver-ca.smoove.pro") && isPath("/api-public/stations") && isMethodGET()) { response in
            if let path = Bundle.main.path(forResource: "Sample Data/stations", ofType: "json") {
                return OHHTTPStubsResponse(
                    fileAtPath: path,
                    statusCode: 200,
                    headers: ["Content-Type":"application/json"]
                    )
                    .requestTime(0.5, responseTime: 0.5)
            } else {
                return OHHTTPStubsResponse()
            }
        }
    }
}
