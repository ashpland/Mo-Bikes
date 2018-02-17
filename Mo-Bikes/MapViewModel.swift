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

enum BikesOrSlots  {
    case bikes
    case slots
}

class MapViewModel {
    static let sharedInstance = MapViewModel()
    var mapView: MKMapView?
    let bikesOrSlots: BehaviorSubject<BikesOrSlots>
    
    init() {
        self.bikesOrSlots = BehaviorSubject<BikesOrSlots>(value: .bikes)
    }
    
    func display(_ stations: [Station]) {
        if let mapView = self.mapView {
            mapView.addAnnotations(stations.annotations())
        }
    }
}

class StationAnnotation: NSObject, MKAnnotation {
    let station: Station
    let coordinate: CLLocationCoordinate2D
    var number: BehaviorSubject<Int> = BehaviorSubject<Int>(value: 5)
    
    init(_ station: Station) {
        self.station = station
        self.coordinate = CLLocationCoordinate2D(latitude: station.coordinate.lat, longitude: station.coordinate.lon)

        super.init()
    }
}

extension Station {
    func annotation() -> StationAnnotation {
        return StationAnnotation(self)
    }
}

extension Array where Element == Station {
    func annotations() -> [StationAnnotation] {
        return self.map{station in station.annotation()}
    }
}


class StationMarker: MKMarkerAnnotationView {
    
    static let reuseID = "StationAnnotationView"
    static let color = (normal: UIColor.blue, low: UIColor.cyan)
    static let glyph = (bikes: "bikeIcon", docks: "dockIcon")
    
    let disposeBag = DisposeBag()
    
    init(station: StationAnnotation,
         numberSub: BehaviorSubject<Int>,
         stateSub: BehaviorSubject<BikesOrSlots>) {
        
        super.init(annotation: station, reuseIdentifier: StationMarker.reuseID)

        //        stateSub.subscribe(onNext: { (bikesOrSlots) in
        //            switch bikesOrSlots {
        //            case .bikes:
        //                self.glyphImage = UIImage(named: StationMarker.glyph.bikes)
        //            case .slots:
        //                self.glyphImage = UIImage(named: StationMarker.glyph.docks)
        //            }
        //        }).disposed(by: disposeBag)
        
        numberSub.subscribe(onNext: { (number) in
            switch number {
            case ..<2:
                self.markerTintColor = StationMarker.color.low
            default:
                self.markerTintColor = StationMarker.color.normal
            }
        }).disposed(by: disposeBag)
        
        

    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension StationAnnotation {
    func marker() -> StationMarker {
        return StationMarker(station: self,
                             numberSub: self.number,
                             stateSub: MapViewModel.sharedInstance.bikesOrSlots)
    }
}



