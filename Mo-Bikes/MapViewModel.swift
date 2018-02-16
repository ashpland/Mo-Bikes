//
//  MapViewModel.swift
//  Mo-Bikes
//
//  Created by Andrew on 2018-02-15.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import Foundation
import MapKit
import UIKit
import RxSwift

let test = UIColor.blue

class MapViewModel {
    static let sharedInstance = MapViewModel()
    let bikesOrSlots: BehaviorSubject<BikesOrSlots>
    
    init() {
        self.bikesOrSlots = BehaviorSubject<BikesOrSlots>(value: .bikes)
    }
}

class StationAnnotation: NSObject, MKAnnotation {
    let station: Station
    let coordinate: CLLocationCoordinate2D
    var number: Observable<Int>
    
    init(_ station: Station) {
        self.station = station
        self.coordinate = CLLocationCoordinate2D(latitude: station.coordinate.lat, longitude: station.coordinate.lon)
//
//        let number: Int
//        switch MapViewModel.sharedInstance.bikesOrSlots {
//        case .bikes:
//            number = station.availableBikes
//        case .slots:
//            number = station.freeSlots
//        }
        
        self.number = BehaviorSubject(value: 0)
        
        super.init()
        
        // TODO: probably need to change the returns below to a stream as opposed to a static variable
        
        self.number = MapViewModel.sharedInstance.bikesOrSlots.flatMap({ (bikesOrSlots) -> Observable<Int> in
            switch bikesOrSlots {
            case .bikes:
                return BehaviorSubject(value: self.station.availableBikes)
            case .slots:
                return BehaviorSubject(value: self.station.freeSlots)
            }
        })
    }
    
    func marker() -> StationMarker {
        
        return StationMarker(station: self,
                             numberSub: self.number,
                             stateSub: MapViewModel.sharedInstance.bikesOrSlots)
    }
}

class StationMarker: MKMarkerAnnotationView {
    
    static let reuseID = "StationAnnotationView"
    static let color = (normal: UIColor.blue, low: UIColor.cyan)
    static let glyph = (bikes: "bikeIcon", docks: "dockIcon")
    
    let disposeBag = DisposeBag()
    
    init(station: StationAnnotation,
         numberSub: Observable<Int>,
         stateSub: BehaviorSubject<BikesOrSlots>) {

        super.init(annotation: station, reuseIdentifier: StationMarker.reuseID)
        
        stateSub.subscribe(onNext: { (bikesOrSlots) in
            switch bikesOrSlots {
            case .bikes:
                self.glyphImage = UIImage(named: StationMarker.glyph.bikes)
            case .slots:
                self.glyphImage = UIImage(named: StationMarker.glyph.docks)
            }
        }).disposed(by: disposeBag)
        
        numberSub.subscribe(onNext: { (number) in
            self.glyphText = String(number)
            
            switch number {
            case ..<2:
                self.glyphTintColor = StationMarker.color.low
            default:
                self.glyphTintColor = StationMarker.color.normal
            }
            
        }).disposed(by: disposeBag)
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

enum BikesOrSlots  {
    case bikes
    case slots
}

