//
//  RMBTMapOperatorButton.swift
//  RMBT
//
//  Created by Polina on 29.09.2021.
//  Copyright © 2021 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTMapOperatorButton: UIButton {
    var op: RMBTMapOperator = RMBTMapOperator.list.first!
    
    override var isHighlighted: Bool {
            get {
                return super.isHighlighted
            }
            set {
                backgroundColor = newValue ? .black.withAlphaComponent(0.05) : .white
                super.isHighlighted = newValue
            }
        }

    init(for op: RMBTMapOperator, within parent: UIView?) {
        super.init(frame: CGRect(x: 0, y: 0, width: parent != nil ? parent!.frame.width : 60, height: 60))
        let heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60)
        self.addConstraint(heightConstraint)
        self.op = op
        self.titleLabel?.font = self.titleLabel?.font.withSize(14)
        self.contentHorizontalAlignment = .left
        self.setTitle(op.shortLabel, for: .normal)
        self.setTitleColor(UIColor.black, for: .normal)
        self.titleEdgeInsets = UIEdgeInsets(top: 22, left: 20, bottom: 22, right: 20)
        let border = CALayer()
        border.backgroundColor = UIColor.black.withAlphaComponent(0.05).cgColor
        border.frame = CGRect(0, self.frame.size.height - 1, self.frame.size.width, 1)
        self.layer.addSublayer(border)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
