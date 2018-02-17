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
    var numAvailable: BehaviorSubject<(bikes: Int, slots: Int)>
    
    init(_ station: Station) {
        self.station = station
        self.coordinate = CLLocationCoordinate2D(latitude: station.coordinate.lat, longitude: station.coordinate.lon)
        self.numAvailable = Observable.combineLatest(station.availableBikes,
                                                  station.freeSlots,
                                                  resultSelector: {(bikes: $0, slots: $1)})
            as! BehaviorSubject<(bikes: Int, slots: Int)>
        
        
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
         numAvailable: BehaviorSubject<(bikes: Int, slots: Int)>,
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
        
        numAvailable.subscribe(onNext: { (number) in
            do {
                switch try stateSub.value() {
                case .bikes:
                    self.updateMarkerColor(number.bikes)
                case .slots:
                    self.updateMarkerColor(number.slots)
                }
            }
                
            catch {
                print("No value in BikesOrSlots")
            }
        }).disposed(by: disposeBag)
        
    }
    
    func updateMarkerColor(_ numAvailable: Int) {
        switch numAvailable {
        case ..<2:
            self.markerTintColor = StationMarker.color.low
        default:
            self.markerTintColor = StationMarker.color.normal
        }
    }
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension StationAnnotation {
    func marker() -> StationMarker {
        return StationMarker(station: self,
                             numAvailable: self.numAvailable,
                             stateSub: MapViewModel.sharedInstance.bikesOrSlots)
    }
}



