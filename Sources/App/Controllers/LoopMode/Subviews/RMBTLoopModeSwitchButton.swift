//
//  RMBTLoopModeSwitchButton.swift
//  RMBT
//
//  Created by Polina on 07.10.2021.
//  Copyright © 2021 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTLoopModeSwitchButton: UIButton {
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? UIColor(rgb: 0xF9D649) : .black.withAlphaComponent(0.05)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView?.layer.transform = CATransform3DMakeScale(1.25, 1.25, 1.25)
    }
    
    override var intrinsicContentSize: CGSize {
       let labelSize = titleLabel?.sizeThatFits(CGSize(width: frame.width, height: .greatestFiniteMagnitude)) ?? .zero
        return CGSize(width: labelSize.width + titleEdgeInsets.left + titleEdgeInsets.right + imageEdgeInsets.left + imageEdgeInsets.right + (imageView?.frameWidth ?? 0), height: labelSize.height + titleEdgeInsets.top + titleEdgeInsets.bottom)
    }
}
