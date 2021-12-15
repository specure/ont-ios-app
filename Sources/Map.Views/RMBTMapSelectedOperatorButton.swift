//
//  RMBTMapSelectedOperatorButton.swift
//  RMBT
//
//  Created by Polina on 28.09.2021.
//  Copyright © 2021 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTMapSelectedOperatorButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        if imageView != nil {
            imageEdgeInsets = UIEdgeInsets(top: 14, left: (bounds.width - 21), bottom: 14, right: 11)
            titleEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: (imageView?.frame.width)!)
            layer.cornerRadius = 16
            layer.borderWidth = 1
            layer.borderColor = UIColor.black.withAlphaComponent(0.05).cgColor
        }
    }
}
