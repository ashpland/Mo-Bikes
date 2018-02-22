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

    let bikesOrSlots: BehaviorSubject<BikesOrSlots>
    let disposeBag = DisposeBag()
    
    init(for mapViewController: MapViewController, with stationManager: StationManager) {
        self.bikesOrSlots = BehaviorSubject<BikesOrSlots>(value: .bikes)
        
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
        
        stationManager.stations.subscribe(onNext: {self.display($0, in: mapViewController.mapView)}).disposed(by: disposeBag)
    }
    
    func display(_ stations: [Station], in mapView: MKMapView) {
        stations.addAnnotations(to: mapView, with: self.bikesOrSlots)
    }
}

extension Station {
    func annotation(in mapView: MKMapView, with stateSub: BehaviorSubject<BikesOrSlots>) -> StationAnnotation {
        return StationAnnotation(self, in: mapView, with: stateSub)
    }
}

extension Array where Element == Station {
    func annotations(in mapView: MKMapView, with stateSub: BehaviorSubject<BikesOrSlots>) -> [StationAnnotation] {
        return self.map{station in station.annotation(in: mapView, with: stateSub)}
    }
    
    func addAnnotations(to mapView: MKMapView, with stateSub: BehaviorSubject<BikesOrSlots>) {
        let _ = self.map{station in station.annotation(in: mapView, with: stateSub)
        }
    }
}


class StationAnnotation: NSObject, MKAnnotation {
    let station: Station
    let coordinate: CLLocationCoordinate2D
    let numAvailable: Observable<(bikes: Int, slots: Int)>
    let stateSub: BehaviorSubject<BikesOrSlots>
    
    init(_ station: Station, in mapView: MKMapView, with stateSub: BehaviorSubject<BikesOrSlots>) {
        self.station = station
        self.coordinate = CLLocationCoordinate2D(latitude: station.coordinate.lat, longitude: station.coordinate.lon)
        self.numAvailable = Observable.combineLatest(station.availableBikes,
                                                     station.freeSlots,
                                                     resultSelector: {(bikes: $0, slots: $1)})
        self.stateSub = stateSub

        super.init()
        
        mapView.addAnnotation(self)

        station.operative.subscribe(onNext: { (operative) in
            switch operative {
            case true: return
            case false:
                mapView.removeAnnotation(self)
                
                return
            }
        }).disposed(by: DisposeBag())
    }
}

extension StationAnnotation {
    func marker() -> StationMarker {
        return StationMarker(station: self,
                             numAvailable: self.numAvailable,
                             stateSub: self.stateSub)
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


