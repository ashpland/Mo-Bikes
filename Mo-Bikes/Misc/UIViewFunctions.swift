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
    blurEffectView &|> fillSuperView
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

func addShadow(view: inout UIView) {
    view.layer
        |> prop(\.shadowColor, value: UIColor.black.cgColor)
        <> prop(\.shadowOpacity, value: 1.0)
        <> prop(\.shadowRadius, value: 1.0)
        <> prop(\.shadowOffset, value: CGSize(width: 1.0, height: 1.0))
}

func roundCorners(_ radius: CGFloat) -> (inout UIView) -> Void {
    return { $0.layer |> prop(\.cornerRadius, value: radius); return }
}

func addBorder(_ color: CGColor, _ width: CGFloat) -> (inout UIView) -> Void {
    return { view in
        view.layer
            |> prop(\.borderColor, value: color)
            <> prop(\.borderWidth, value: width)
        return
    }
}

func addBorder(_ style: (color: CGColor, width: CGFloat)) -> (inout UIView) -> Void {
    return addBorder(style.color, style.width)
}

func inRadians(_ degrees: CGFloat) -> CGFloat {
    print("degrees: \(degrees)")
    return degrees / 180 * CGFloat.pi
}

func setRotate(_ radians: CGFloat) -> (UIView) -> Void{
    return { view in
        let current = CGFloat(atan2f(Float(view.transform.b), Float(view.transform.a)))
        print("current: \(current), new: \(radians)")
        view.transform = view.transform.rotated(by: radians - current)
    }
}
