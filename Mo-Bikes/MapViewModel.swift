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

enum BikesOrDocks  {
    case bikes
    case docks
}

class MapViewModel {

    let bikesOrDocks = BehaviorSubject<BikesOrDocks>(value: .bikes)
    let stationAnnotations = PublishSubject<[StationAnnotation]>()
    let removeAnnotations = PublishSubject<StationAnnotation>()
    let disposeBag = DisposeBag()
    
    init(_ stationManager: StationManager) {
        stationManager.stations.asObservable()
            .map { $0.map { StationAnnotation(station: $0,
                                              stateSub: self.bikesOrDocks,
                                              disposal: self.removeAnnotations) } }
            .bind(to: stationAnnotations)
            .disposed(by: disposeBag)
    }
}

class StationAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let numAvailable: Observable<(bikes: Int, docks: Int)>
    let stateSub: Observable<BikesOrDocks>
    
    init(station: Station, stateSub: Observable<BikesOrDocks>, disposal: PublishSubject<StationAnnotation>) {
        self.coordinate = CLLocationCoordinate2D(latitude: station.coordinate.lat,
                                                 longitude: station.coordinate.lon)
        self.numAvailable = Observable.combineLatest(station.availableBikes,
                                                     station.availableDocks,
                                                     resultSelector: {(bikes: $0, docks: $1)})
        self.stateSub = stateSub

        super.init()
        
        station.operative
            .filter { !$0 }
            .map { _ in self}
            .bind(to: disposal)
            .disposed(by: DisposeBag())
    }
}

extension StationAnnotation {
    var marker: StationMarker {
        return StationMarker(station: self,
                             numAvailable: self.numAvailable,
                             stateSub: self.stateSub)
    }
}


class StationMarker: MKMarkerAnnotationView {
    
    struct Constants {
        static let reuseID = "StationAnnotationView"
        static let lowNumber = 2
        static let color = (normal: #colorLiteral(red: 0.5791940689, green: 0.1280144453, blue: 0.5726861358, alpha: 1),
                            low: #colorLiteral(red: 0.7806914647, green: 0.5464840253, blue: 0.7773131953, alpha: 1))
        static let glyphs = (bikes: UIImage(named: "bikeIcon"),
                             docks: UIImage(named: "dockIcon"))
    }
    
    let currentlySelected = BehaviorSubject<Bool>(value: false)
    let disposeBag = DisposeBag()
    
    init(station: StationAnnotation,
         numAvailable: Observable<(bikes: Int, docks: Int)>,
         stateSub: Observable<BikesOrDocks>) {
        
        super.init(annotation: station, reuseIdentifier: Constants.reuseID)
        
        Observable
            .combineLatest(stateSub, numAvailable, currentlySelected)
            .map { (state, numAvailable, selected) -> (available: Int, glyph: UIImage?, isSelected: Bool) in
                switch state {
                case .bikes:
                    return(available: numAvailable.bikes,
                           glyph: Constants.glyphs.bikes,
                           isSelected: selected)
                case .docks:
                    return(available: numAvailable.docks,
                           glyph: Constants.glyphs.docks,
                           isSelected: selected)
                }
            }
            .subscribe(onNext: { (current) in
                self.updateMarkerColor(current.available)
                self.glyphText  = current.isSelected ? String(current.available) : nil
                self.glyphImage = current.isSelected ? nil : current.glyph
            })
            .disposed(by: disposeBag)
    }
    
    func updateMarkerColor(_ numAvailable: Int) {
        switch numAvailable {
        case ..<Constants.lowNumber:
            self.markerTintColor = Constants.color.low
        default:
            self.markerTintColor = Constants.color.normal
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


