//
//  Styles.swift
//  Mo-Bikes
//
//  Created by Andrew on 2018-10-02.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import UIKit

enum Styles {

    struct ButtonImages {
        let bikesSelected = #imageLiteral(resourceName: "bikeIcon-invert")
        let bikesUnselected =  #imageLiteral(resourceName: "bikeIcon")
        let docksSelected =  #imageLiteral(resourceName: "dockIcon-invert")
        let docksUnselected =  #imageLiteral(resourceName: "dockIcon")
    }

    static let glyphImage = (bikes:    #imageLiteral(resourceName: "bikeIcon"),
                             docks:    #imageLiteral(resourceName: "dockIcon"),
                             fountain: #imageLiteral(resourceName: "fountain"),
                             washroom: #imageLiteral(resourceName: "toilet"))

    static let buttonImages = (bikesSelected: #imageLiteral(resourceName: "bikeIcon-invert"),
                               bikesUnselected: #imageLiteral(resourceName: "bikeIcon"),
                               docksSelected: #imageLiteral(resourceName: "dockIcon-invert"),
                               docksUnselected: #imageLiteral(resourceName: "dockIcon"))

    static let lowAvailable = 2

    static let buttonCorners: CGFloat = 11.25

    static let border: (color: CGColor, width: CGFloat) = (Color.border.cgColor, 0.5)

    static let trayCornerRadius: CGFloat = 20
    static let bounceHeight: CGFloat = 50

    enum Color {
        static let primary = #colorLiteral(red: 0.5791940689, green: 0.1280144453, blue: 0.5726861358, alpha: 1)
        static let secondary = #colorLiteral(red: 0.3018391927, green: 0.6276475694, blue: 1, alpha: 1)
        static let lightPrimary = #colorLiteral(red: 0.7806914647, green: 0.5464840253, blue: 0.7773131953, alpha: 1)
        static let inactive = #colorLiteral(red: 0.754, green: 0.7540867925, blue: 0.754, alpha: 1)
        static let border = #colorLiteral(red: 0.75, green: 0.75, blue: 0.75, alpha: 0.5039865154)

        static let marker = (normal: Color.primary,
                             low: Color.lightPrimary)
    }
}

func secondaryTintColor(_ isOn: Bool) -> UIColor {
    return isOn ? Styles.Color.secondary : Styles.Color.inactive
}

func markerColor(_ currentAvailable: Int) -> UIColor {
    return currentAvailable > Styles.lowAvailable ? Styles.Color.marker.normal : Styles.Color.marker.low
}
