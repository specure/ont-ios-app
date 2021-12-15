//
//  UIButton.swift
//  RMBT
//
//  Created by Polina on 27.09.2021.
//  Copyright © 2021 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTMapTechnologyButton: UIButton {
    var technology: RMBTMapTechnology = RMBTMapTechnology.list.first!
    
    init(for tech: RMBTMapTechnology) {
        super.init(frame: CGRect(x: 0, y: 0, width: 56, height: 32))
        self.technology = tech
        self.setTitle(tech.label, for: .normal)
        self.titleLabel?.font = self.titleLabel?.font.withSize(12)
        self.layer.cornerRadius = 16
        let widthConstraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 56)
        self.addConstraint(widthConstraint)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func colorizeIf(_ isSelected: Bool, color: UIColor) {
        if (isSelected) {
            self.backgroundColor = color
            self.setTitleColor(technology.textColor, for: .normal)
        } else {
            self.backgroundColor = UIColor.black.withAlphaComponent(0.05)
            self.setTitleColor(UIColor.black, for: .normal)
        }
    }
}
