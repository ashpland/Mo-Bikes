//
//  MapViewModel.swift
//  Mo-Bikes
//
//  Created by Andrew on 2018-02-15.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import MapKit
import RxSwift
import RxCocoa

enum BikesOrDocksState  {
    case bikes
    case docks
}

class MapViewModel: NSObject {

    let bikesOrDocks = BehaviorRelay<BikesOrDocksState>(value: .bikes)
    var stationsDriver: Driver<[Station]> {
        return stations.asDriver()
    }
    var stationsToRemoveSignal: Signal<Station> {
        return stationsToRemove.asSignal()
    }
    
    private let stations = BehaviorRelay(value: [Station]())
    private let stationsToRemove = PublishRelay<Station>()
    private let disposeBag = DisposeBag()
    
    func updateStations() {
        let networkResponse = Single.just([Station]())
        
        networkResponse
            .subscribe(onSuccess: { [weak self] updatedStations in
                guard let `self` = self else { return }
                
                var currentStations = self.stations.value.asDictionary
                let updatedStations = updatedStations.asDictionary
                
                let keysToRemove = currentStations.asSetOfKeys.subtracting(updatedStations.asSetOfKeys)
                
                for key in keysToRemove {
                    if let inactiveStation = currentStations.removeValue(forKey: key) {
                        self.stationsToRemove.accept(inactiveStation)
                    }
                }
                
                currentStations.merge(updatedStations) { currentStation, updatedStation in
                    return currentStation.updated(from: updatedStation)
                }
                
                self.stations.accept(currentStations.map { $0.value })
            })
            .disposed(by: disposeBag)
    }

}

extension Array where Element == Station {
    var asDictionary: [String : Station] {
        return self.reduce(into: [String : Station](), { dictionary, station in
            dictionary[station.name] = station
        })
    }
}

extension Dictionary {
    var asSetOfKeys: Set<Key> {
        return Set(self.map({$0.key}))
    }
}


import Alamofire

class Networker {
    func temp() {
        
        Alamofire
            .request("https://vancouver-ca.smoove.pro/api-public/stations",
                     method: .get)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
        
        
    }
}
