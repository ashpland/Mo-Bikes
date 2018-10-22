
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
