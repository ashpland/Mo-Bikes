//
//  StationView.swift
//  Mo-Bikes
//
//  Created by Andrew on 2018-10-02.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import MapKit
import RxSwift
import RxCocoa

class StationView: MKMarkerAnnotationView {

    var viewModel: StationViewModel! {
        didSet {
            setupRx()
        }
    }

    private var disposeBag = DisposeBag()

    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }

    func setupRx() {
        viewModel.markerTintColor
            .drive(rx.markerTintColor)
            .disposed(by: disposeBag)

        viewModel.glyphText
            .drive(rx.glyphText)
            .disposed(by: disposeBag)

        viewModel.glyphImage
            .drive(rx.glyphImage)
            .disposed(by: disposeBag)
    }

}
