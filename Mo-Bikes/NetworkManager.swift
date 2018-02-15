//
//  NetworkManager.swift
//  Mo-Bikes
//
//  Created by Andrew on 2018-02-15.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import Foundation
import Alamofire

class NetworkManager {
    static let sharedInstance = NetworkManager()
    
    func updateStationData() {
        Alamofire.request("https://vancouver-ca.smoove.pro/api-public/stations",
                          method: .get)
            .responseJSON { (response) in
                guard response.result.isSuccess else {
                    print("Error while fetching page: \(String(describing: response.result.error))")
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    print("Invalid page information recieved from the service")
                    return
                }
                
                print(responseJSON)
        }
    }
}
