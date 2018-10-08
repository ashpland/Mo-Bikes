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
import Alamofire

enum BikesOrDocksState {
    case bikes
    case docks
}

class MapViewModel {

    let bikesOrDocks = BehaviorRelay<BikesOrDocksState>(value: .bikes)

    var stationsToAddDriver: Driver<[MKAnnotation]> {
        return stations.asDriver().map { $0.map { $0 as MKAnnotation } }
    }
    var stationsToRemoveSignal: Signal<MKAnnotation> {
        return stationsToRemove.asSignal().map { $0 as MKAnnotation }
    }

    private let stations = BehaviorRelay(value: [Station]())
    private let stationsToRemove = PublishRelay<Station>()
    private let disposeBag = DisposeBag()

    func updateStations(from updatedStationData: [StationData]) {
        guard !updatedStationData.isEmpty else { return }

        var currentStations = stations.value.asDictionary
        let updatedStations = updatedStationData.asDictionary
        let keysToRemove = currentStations.asSetOfKeys.subtracting(updatedStations.asSetOfKeys)

        for key in keysToRemove {
            if let inactiveStation = currentStations.removeValue(forKey: key) {
                stationsToRemove.accept(inactiveStation)
            }
        }

        for station in currentStations {
            if let updatedData = updatedStations[station.key] {
                station.value.stationData = updatedData
            }
        }

        let keysToAdd = updatedStations.asSetOfKeys.subtracting(currentStations.asSetOfKeys)

        for key in keysToAdd {
            if let newStationData = updatedStations[key] {
                currentStations[key] = Station(newStationData)
            }
        }

        stations.accept(currentStations.map { $0.value })
    }

    func getStationData() -> Single<[StationData]> {
        return Single<[StationData]>.create { single -> Disposable in
            let request = Alamofire
                .request("https://vancouver-ca.smoove.pro/api-public/stations",
                         method: .get)
                .validate(statusCode: 200..<300)
                .validate(contentType: ["application/json"])
                .responseData(completionHandler: { response in
                    switch response.result {
                    case .success(let data):
                        if let stations = StationData.decode(from: data) {
                            single(.success(stations))
                        } else {
                            single(.error(JSONError()))
                        }
                    case .failure(let error):
                        single(.error(error))
                    }
                })
            return Disposables.create(with: request.cancel)
        }
    }
}

protocol NameIndexable {
    var name: String { get }
}

extension Array where Element: NameIndexable {
    var asDictionary: [String: Element] {
        return self.reduce(into: [String: Element]()) { dictionary, element in
            dictionary[element.name] = element
        }
    }
}

extension Dictionary {
    var asSetOfKeys: Set<Key> {
        return Set(self.map({$0.key}))
    }
}

struct JSONError: LocalizedError {
    var errorDescription: String? {
        return "JSON Decoding Error"
    }
}
