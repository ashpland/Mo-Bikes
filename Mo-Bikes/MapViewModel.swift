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
    var bikesOrSlots: BikesOrSlots = .bikes
    let currentGlyph: BehaviorSubject<UIImage>
    
    init() {
        self.currentGlyph = BehaviorSubject<UIImage>(value: UIImage())
    }
}

class StationAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let number: BehaviorSubject<Int>
    
    init(_ station: Station) {
        self.coordinate = CLLocationCoordinate2D(latitude: station.coordinate.lat, longitude: station.coordinate.lon)
        
        let number: Int
        switch MapViewModel.sharedInstance.bikesOrSlots {
        case .bikes:
            number = station.availableBikes
        case .slots:
            number = station.freeSlots
        }
        
        self.number = BehaviorSubject<Int>(value: number)
    }
    
    func marker() -> StationMarker {
        
        
        return StationMarker(station: self,
                             numberSub: self.number,
                             glyphSub: MapViewModel.sharedInstance.currentGlyph)
    }
}

class StationMarker: MKMarkerAnnotationView {
    
    static let reuseID = "StationAnnotationView"
    static let color = (normal: UIColor.blue, low: UIColor.cyan)
    
    let disposeBag = DisposeBag()
    
    init(station: StationAnnotation,
         numberSub: BehaviorSubject<Int>,
         glyphSub: BehaviorSubject<UIImage>) {

        super.init(annotation: station, reuseIdentifier: StationMarker.reuseID)
        
        glyphSub.subscribe(onNext: { (newImage) in
            self.glyphImage = newImage
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

