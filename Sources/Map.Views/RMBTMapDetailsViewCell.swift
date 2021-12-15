//
//  RMBTMapDetailsViewCell.swift
//  RMBT
//
//  Created by Polina on 05.10.2021.
//  Copyright © 2021 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTMapDetailsViewCell: UITableViewCell {
    let labelView = UILabel()
    let valueView = UILabel()
    let contentStackView = UIStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        initContentStackView()
        initConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func initContentStackView() {
        labelView.textColor = .black.withAlphaComponent(0.5)
        labelView.font = UIFont.systemFont(ofSize: 14)
        valueView.textAlignment = .right
        valueView.textColor = .black
        valueView.font = UIFont.systemFont(ofSize: 14)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .horizontal
        contentStackView.distribution = .fill
        contentStackView.alignment = .center
        contentStackView.backgroundColor = .white
        contentStackView.addArrangedSubview(labelView)
        contentStackView.addArrangedSubview(valueView)
        contentView.addSubview(contentStackView)
        contentView.backgroundColor = .white
    }
    
    private func initConstraints() {
        let leftConstraint = NSLayoutConstraint(item: contentStackView, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1, constant: 20)
        let topConstraint = NSLayoutConstraint(item: contentStackView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: contentStackView, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1, constant: -20)
        let bottomConstraint = NSLayoutConstraint(item: contentStackView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0)
        contentView.addConstraints([leftConstraint, topConstraint, rightConstraint, bottomConstraint])
        preservesSuperviewLayoutMargins = false
        separatorInset = UIEdgeInsets.zero
        layoutMargins = UIEdgeInsets.zero
    }
}
