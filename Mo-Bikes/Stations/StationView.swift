//
//  StationView.swift
//  Mo-Bikes
//
//  Created by Andrew on 2018-10-02.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import MapKit

class StationView: MKMarkerAnnotationView {
    var stationData: StationData!
}

func configureStationView(_ bikesOrDocksState: BikesOrDocks) -> (StationView) -> StationView {
    return { view in
        let currentAvailable: Int = {
            switch bikesOrDocksState {
            case .bikes:
                return view.stationData.availableBikes
            case .docks:
                return view.stationData.availableDocks
            }
        }()
        view.markerTintColor = currentAvailable |> markerColor
        view.glyphText = view.isSelected ? String(currentAvailable) : nil
        view.glyphImage = view.isSelected ? nil : bikesOrDocksState.glyph
        view.animatesWhenAdded = true

        return view
    }
}

func markerColor(_ currentAvailable: Int) -> UIColor {
    return currentAvailable > Styles.lowAvailable ? Styles.Color.marker.normal : Styles.Color.marker.low
}
