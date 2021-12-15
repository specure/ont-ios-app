//
//  RMBTStartTestButton.swift
//  RMBT
//
//  Created by Polina on 07.10.2021.
//  Copyright © 2021 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTStartTestButton: RMBTGradientButton {
    override var isHighlighted: Bool {
        get {
            return false
        }
        set {
            return
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.sublayers?.forEach({layer in
            layer.cornerRadius = 30
        })
        titleLabel?.textColor = RMBTColorManager.buttonTitleColor
    }
}
