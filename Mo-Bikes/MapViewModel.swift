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

    let bikesOrDocks: BehaviorSubject<BikesOrDocks>
    let disposeBag = DisposeBag()
    
    init(for mapViewController: MapViewController, with stationManager: StationManager) {
        
        self.bikesOrDocks = BehaviorSubject<BikesOrDocks>(value: .bikes)
        
        mapViewController.bikesDocksControl.rx.selectedSegmentIndex
            .map { return $0 == 0 ? .bikes : .docks }
            .bind(to: bikesOrDocks)
            .disposed(by: disposeBag)
        
        stationManager.stations
            .subscribe(onNext: { self.display($0, in: mapViewController.mapView) } )
            .disposed(by: disposeBag)
    }
    
    func display(_ stations: [Station], in mapView: MKMapView) {
        stations.addAnnotations(to: mapView, with: self.bikesOrDocks)
    }
}

extension Station {
    func annotation(in mapView: MKMapView,
                    with stateSub: Observable<BikesOrDocks>) -> StationAnnotation {
        return StationAnnotation(self, in: mapView, with: stateSub)
    }
}

extension Array where Element == Station {
    func addAnnotations(to mapView: MKMapView,
                        with stateSub: Observable<BikesOrDocks>) {
        let _ = self.map{ station in station.annotation(in: mapView, with: stateSub) }
    }
}


class StationAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let numAvailable: Observable<(bikes: Int, docks: Int)>
    let stateSub: Observable<BikesOrDocks>
    
    init(_ station: Station, in mapView: MKMapView, with stateSub: Observable<BikesOrDocks>) {
        self.coordinate = CLLocationCoordinate2D(latitude: station.coordinate.lat,
                                                 longitude: station.coordinate.lon)
        self.numAvailable = Observable.combineLatest(station.availableBikes,
                                                     station.availableDocks,
                                                     resultSelector: {(bikes: $0, docks: $1)})
        self.stateSub = stateSub

        super.init()
        
        mapView.addAnnotation(self)

        station.operative
            .subscribe(onNext: { if !$0 { mapView.removeAnnotation(self) } })
            .disposed(by: DisposeBag())
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


