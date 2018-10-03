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

enum BikesOrDocksState {
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
    var asDictionary: [String: Station] {
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

        // Wrap in Single

        Alamofire
            .request("https://vancouver-ca.smoove.pro/api-public/stations",
                     method: .get)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseData(completionHandler: { response in
                switch response.result {
                case .success(let data):
                    let decoder = JSONDecoder()

                    guard let stations = try? decoder.decode(TestStationList.self, from: data) else { print("It broke"); return } // decoding error
                    print(stations.result.map { $0.coordinate })

                case .failure(let error):
                    print(error.localizedDescription) // network error
                }
            })

    }
}

class TestStation: NSObject, MKAnnotation, Decodable {
    let name: String
    let coordinates: String
    let totalDocks: Int
    let availableDocks: Int
    let availableBikes: Int
    let operative: Bool

    enum CodingKeys: String, CodingKey {
        case name
        case coordinates
        case totalDocks = "total_slots"
        case availableDocks = "free_slots"
        case availableBikes = "avl_bikes"
        case operative
    }

    var coordinate: CLLocationCoordinate2D {
        let splitCoordinates = coordinates
            .split(separator: ",")
            .map { String($0.trimmingCharacters(in: .whitespaces)) }

        guard let latString = splitCoordinates.first,
            let lonString = splitCoordinates.last,
            let lat = Double(latString),
            let lon = Double(lonString)
            else { return kCLLocationCoordinate2DInvalid }

        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

}

// {"name":"0001 10th & Cambie","coordinates":"49.262487, -123.114397","total_slots":52,"free_slots":32,"avl_bikes":20,"operative":true,"style":""}

struct TestStationList: Decodable {
    let result: [TestStation]
}
