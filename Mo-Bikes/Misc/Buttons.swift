//
//  Buttons.swift
//  Mo-Bikes
//
//  Created by Andrew on 2018-10-17.
//  Copyright © 2018 hearthedge. All rights reserved.
//

import UIKit

enum MoButtonType {
    case generic
    case bikes
    case docks
    case washrooms
    case fountains
    case contact
    case compass
    case menu
}

class MoButton: UIButton { var type: MoButtonType { return .generic } }

class MoButtonContact: MoButton { override var type: MoButtonType { return .contact } }
class MoButtonCompass: MoButton { override var type: MoButtonType { return .compass } }

class MoButtonToggle: MoButton { var isOn = false }

class MoButtonMenu: MoButtonToggle { override var type: MoButtonType { return .menu } }
class MoButtonWashrooms: MoButtonToggle { override var type: MoButtonType { return .washrooms } }
class MoButtonFountains: MoButtonToggle { override var type: MoButtonType { return .fountains } }
class MoButtonBikes: MoButtonToggle { override var type: MoButtonType { return .bikes } }
class MoButtonDocks: MoButtonToggle { override var type: MoButtonType { return .docks } }

func setButtonImage(to imageKP: KeyPath<Styles.ButtonImages, UIImage>) -> (UIButton) -> Void {
    return { button in
        button.setImage(Styles.ButtonImages()[keyPath: imageKP], for: .normal)
    }
}
