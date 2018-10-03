//
//  StationViewModel.swift
//  Mo-Bikes
//
//  Created by Andrew on 2018-10-02.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import RxSwift
import RxCocoa

class StationViewModel {

    let markerTintColor: Driver<UIColor?>
    let glyphText: Driver<String?>
    let glyphImage: Driver<UIImage?>
    let stationIsSelected = BehaviorRelay<Bool>(value: false)

    init(station: Station, bikesOrDocksState: Driver<BikesOrDocksState>) {

        let currentAvailable: Driver<Int> = Driver
            .combineLatest(bikesOrDocksState,
                           station.availableBikes.asDriver(),
                           station.availableDocks.asDriver())
            .map { bikesOrDocksState, availableBikes, availableDocks in
                switch bikesOrDocksState {
                case .bikes:
                    return availableBikes
                case .docks:
                    return availableDocks
                }
        }

        self.markerTintColor = currentAvailable
            .map { $0 > Styles.lowAvailable ? Styles.markerColor.normal : Styles.markerColor.low }

        self.glyphText = Driver
            .combineLatest(stationIsSelected.asDriver(),
                           currentAvailable)
            .map { currentlySelected, currentAvailable in
                return currentlySelected ? String(currentAvailable) : nil
        }

        self.glyphImage = Driver
            .combineLatest(stationIsSelected.asDriver(),
                           bikesOrDocksState)
            .map { currentlySelected, bikesOrDocksState in
                guard !currentlySelected else { return nil }
                switch bikesOrDocksState {
                case .bikes:
                    return Styles.glyphs.bikes
                case .docks:
                    return Styles.glyphs.docks
                }
        }

    }
}
