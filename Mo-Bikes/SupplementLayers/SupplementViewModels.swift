//
//  SupplementViewModels.swift
//  Mo-Bikes
//
//  Created by Andrew on 2018-10-17.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import MapKit

func configureMarker(_ marker: MKMarkerAnnotationView, for annotation: SupplementAnnotation) -> MKMarkerAnnotationView {
    marker.glyphImage = annotation.pointType.glyphImage
    marker.markerTintColor = Styles.Color.secondary
    marker.isEnabled = false
    return marker
}

func configurePolylineRenderer(for supplementPolyline: SupplementPolyline) -> MKPolylineRenderer {
    let renderer = MKPolylineRenderer(polyline: supplementPolyline)
    renderer.strokeColor = Styles.Color.secondary
    renderer.lineWidth = 3.0

    if let lineType = supplementPolyline.lineType,
        case .bikeRouteDashed = lineType {
        renderer.lineDashPattern =  [5, 5]
    }

    return renderer
}
