//
//  TrayView.swift
//  Mo-Bikes
//
//  Created by Andrew on 2018-10-21.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import UIKit

class TrayView: UIView {

    var delegate: TrayViewDelegate?

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        delegate?.trayViewTouchesMoved(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        delegate?.trayViewTouchesEnded()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        delegate?.trayViewTouchesEnded()
    }
}

protocol TrayViewDelegate {
    func trayViewTouchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    func trayViewTouchesEnded()
}

enum TrayState {
    case bounceOpen(_ mvc: MapViewController)
    case open(_ mvc: MapViewController)
    case closed(_ mvc: MapViewController)
    case partial(bottomConstant: CGFloat, alpha: CGFloat, iconRotation: CGFloat)

    var constant: CGFloat {
        switch self {
        case .bounceOpen(let mvc):
            return mvc.bounceOpenHeight
        case .open(let mvc):
            return mvc.openHeight
        case .closed(let mvc):
            return mvc.closedHeight
        case .partial(let bottomConstant, _, _):
            return bottomConstant
        }
    }

    var alpha: CGFloat {
        switch self {
        case .bounceOpen, .open:
            return 1.0
        case .closed:
            return 0.0
        case .partial(_, let alpha, _):
            return alpha
        }
    }

    var rotation: CGFloat {
        switch self {
        case .bounceOpen, .open:
            return 90.0
        case .closed:
            return 0.0
        case .partial(_, _, let iconRotation):
            return iconRotation
        }
    }
}
