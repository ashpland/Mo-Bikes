//
//  SupplementMarker.swift
//  Mo-Bikes
//
//  Created by Andrew on 2018-10-18.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import MapKit

// MARK: Point

enum SupplementPointType: String, CaseIterable {
    case fountain = "drinking_fountains"
    case washroom = "public_washrooms"

    var fileURL: URL {
        return Bundle.main.url(forResource: self.rawValue, withExtension: "kml")!
    }

    var glyphImage: UIImage {
        switch self {
        case .fountain:
            return Styles.glyphImage.fountain
        case .washroom:
            return Styles.glyphImage.washroom
        }
    }
}

func stringToAnnotation(of pointType: SupplementPointType) -> (PointCoordinate) -> SupplementAnnotation {
    return { string in
        return SupplementAnnotation(coordinate: string |> stringToCLLocationCoordinate2D,
                                    pointType: pointType)
    }
}

// MARK: - Annotation

class SupplementAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let pointType: SupplementPointType

    init(coordinate: CLLocationCoordinate2D, pointType: SupplementPointType) {
        self.coordinate = coordinate
        self.pointType = pointType
        super.init()
    }
}

func justAnnotations(of pointType: SupplementPointType) -> (MKAnnotation) -> SupplementAnnotation? {
    return { annotation in
        if let supplementAnnotation = annotation as? SupplementAnnotation,
            supplementAnnotation.pointType == pointType {
            return supplementAnnotation
        } else {
            return nil
        }
    }
}

func loadSupplementAnnotations(of pointType: SupplementPointType) throws -> [MKAnnotation] {
    return try pointType.fileURL
        |>  getXMLDocument
        >>> getPlacemarkElements
        >>> compactMap(getPointCoordinateString)
        >>> map(stringToAnnotation(of: pointType))
        >>> removeDuplicates
}

func removeDuplicates<Element: Hashable>(_ array: [Element]) -> [Element] {
    return Array(Set(array))
}

// MARK: - Marker

func configureMarker(for annotation: SupplementAnnotation) -> (inout MKMarkerAnnotationView) -> MKMarkerAnnotationView {
    return { marker in
        marker.glyphImage = annotation.pointType.glyphImage
        marker.markerTintColor = Styles.Color.secondary
        marker.isEnabled = false
        marker.animatesWhenAdded = true
        return marker
    }
}
