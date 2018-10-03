//
//  StationView.swift
//  Mo-Bikes
//
//  Created by Andrew on 2018-10-02.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import MapKit
import RxSwift

class StationView: MKMarkerAnnotationView {
    private let disposeBag = DisposeBag()
    
    var viewModel: StationViewModel! {
        didSet {
            setupRx()
        }
    }
    
    func setupRx() {
        viewModel.markerTintColor
            .drive(onNext: { self.markerTintColor = $0 })
            .disposed(by: disposeBag)
        
        viewModel.glyphText
            .drive(onNext: { self.glyphText = $0 })
            .disposed(by: disposeBag)
        
        viewModel.glyphImage
            .drive(onNext: { self.glyphImage = $0 })
            .disposed(by: disposeBag)
    }
    
}
