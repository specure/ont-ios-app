//
//  RMBTMapSelectedDateButton.swift
//  RMBT
//
//  Created by Polina on 30.09.2021.
//  Copyright © 2021 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTMapSelectedDateButton: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        layer.cornerRadius = 16
    }
    
    override var intrinsicContentSize: CGSize {
       let labelSize = titleLabel?.sizeThatFits(CGSize(width: frame.width, height: .greatestFiniteMagnitude)) ?? .zero
       return CGSize(width: labelSize.width + titleEdgeInsets.left + titleEdgeInsets.right, height: labelSize.height + titleEdgeInsets.top + titleEdgeInsets.bottom)
    }
}
