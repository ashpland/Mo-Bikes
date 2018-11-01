//
//  UIViewFunctions.swift
//  Mo-Bikes
//
//  Created by Andrew on 2018-10-23.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import UIKit

func blurBackground(_ view: inout UIView) {
    view.backgroundColor = UIColor.clear
    let blurEffectView = UIBlurEffect(style: UIBlurEffect.Style.light) |> UIVisualEffectView.init
    view.insertSubview(blurEffectView, at: 0)
    blurEffectView &> fillSuperView
}

func fillSuperView(_ view: inout UIView) {
    guard let superview = view.superview else { return }

    view.translatesAutoresizingMaskIntoConstraints = false

    [view.topAnchor.constraint(equalTo: superview.topAnchor),
     view.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
     view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
     view.trailingAnchor.constraint(equalTo: superview.trailingAnchor)]
        |> NSLayoutConstraint.activate
}

func roundCorners(_ radius: CGFloat) -> (inout UIView) -> Void {
    return { $0.layer &> set(\.cornerRadius, to: radius); return }
}

func addBorder(_ style: (color: CGColor, width: CGFloat)) -> (inout UIView) -> Void {
    return {
        $0.layer
            &> set(\.borderColor, to: style.color)
            <> set(\.borderWidth, to: style.width)
    }
}

func inRadians(_ degrees: CGFloat) -> CGFloat {
    return degrees / 180 * CGFloat.pi
}

func setRotate(_ radians: CGFloat) -> (inout UIView) -> Void {
    return { view in
        view.transform = view.transform.rotated(by: radians - currentRotation(of: view))
    }
}

/// Returns current rotation of view in radians
func currentRotation(of view: UIView) -> CGFloat {
    return CGFloat(atan2f(Float(view.transform.b), Float(view.transform.a)))
}
