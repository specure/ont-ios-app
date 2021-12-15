//
//  RMBTSearchField.swift
//  RMBT
//
//  Created by Polina on 27.09.2021.
//  Copyright © 2021 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTSearchField: UITextField {
    let padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 48)
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
}
