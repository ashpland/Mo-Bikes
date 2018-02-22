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
    
    var stationAnnotations = [String : StationAnnotation]()
    
    var mapView: MKMapView?
    let bikesOrSlots: BehaviorSubject<BikesOrSlots>
    let disposeBag = DisposeBag()
    var mapViewController: MapViewController? {
        didSet {
            if let mapViewController = mapViewController {
                mapViewController.bikesDocksControl.rx.selectedSegmentIndex.subscribe(onNext: { (segmentIndex) in
                    switch segmentIndex {
                    case 0:
                        self.bikesOrSlots.onNext(.bikes)
                    case 1:
                        self.bikesOrSlots.onNext(.slots)
                    default:
                        return
                    }
                }).disposed(by: disposeBag)                
            }
        }
    }
    
    init() {
        self.bikesOrSlots = BehaviorSubject<BikesOrSlots>(value: .bikes)
    }
    
    func display(_ stations: [Station]) {
        
        self.stationAnnotations = stations.map{$0.annotation()}
            .reduce([String : StationAnnotation](), { (dict, stationAnnotation) -> [String : StationAnnotation] in
                return dict.merging([stationAnnotation.station.name : stationAnnotation], uniquingKeysWith: {$1})
            })
        
        if let mapView = self.mapView {
            mapView.addAnnotations(self.stationAnnotations.map({$1}))
            mapView.addAnnotations(self.stationAnnotations.map({$1}))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 50.0, execute: {
                mapView.removeAnnotations(self.stationAnnotations.map({$1}))
                mapView.removeAnnotation(StationAnnotation(Station(name: "hey", coordinate: (2,2), totalSlots: 2, freeSlots: 2, availableBikes: 2, operative: true)))

            })
        }
    }
    
    
}

class StationAnnotation: NSObject, MKAnnotation {
    let station: Station
    let coordinate: CLLocationCoordinate2D
    var numAvailable: Observable<(bikes: Int, slots: Int)>
    
    init(_ station: Station) {
        self.station = station
        self.coordinate = CLLocationCoordinate2D(latitude: station.coordinate.lat, longitude: station.coordinate.lon)
        self.numAvailable = Observable.combineLatest(station.availableBikes,
                                                     station.freeSlots,
                                                     resultSelector: {(bikes: $0, slots: $1)})
        super.init()
    }
}

extension StationAnnotation {
    func marker() -> StationMarker {
        return StationMarker(station: self,
                             numAvailable: self.numAvailable,
                             stateSub: MapViewModel.sharedInstance.bikesOrSlots)
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
    static let color = (normal: #colorLiteral(red: 0.5791940689, green: 0.1280144453, blue: 0.5726861358, alpha: 1),
                        low: #colorLiteral(red: 0.7806914647, green: 0.5464840253, blue: 0.7773131953, alpha: 1))
    static let glyph = (bikes: "bikeIcon",
                        docks: "dockIcon")
    
    let currentNumber = BehaviorSubject<String>(value: "0")
    
    let unsubscribeNumber = PublishSubject<Void>()
    let disposeBag = DisposeBag()
    
    init(station: StationAnnotation,
         numAvailable: Observable<(bikes: Int, slots: Int)>,
         stateSub: BehaviorSubject<BikesOrSlots>) {
        
        super.init(annotation: station, reuseIdentifier: StationMarker.reuseID)
        
        Observable.combineLatest(stateSub, numAvailable){(state: $0, available: $1)}
            .subscribe(onNext: { (latest) in
                switch latest.state {
                case .bikes:
                    self.updateNumber(latest.available.bikes)
                    self.glyphImage = UIImage(named: StationMarker.glyph.bikes)
                case .slots:
                    self.updateNumber(latest.available.slots)
                    self.glyphImage = UIImage(named: StationMarker.glyph.docks)
                }
            }).disposed(by: disposeBag)
    }
    
    func updateNumber(_ numAvailable: Int) {
        self.updateMarkerColor(numAvailable)
        self.currentNumber.onNext(String(numAvailable))
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


