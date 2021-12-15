//
//  RMBTNetworkInfoDetailsCell.swift
//  RMBT
//
//  Created by Polina on 08.10.2021.
//  Copyright © 2021 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTNetworkInfoDetailsCell: UITableViewCell {
    static let id = "RMBTNetworkInfoDetailsCell"
    
    @IBOutlet weak var detailsStackView: UIStackView?
    @IBOutlet weak var ipvButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func toggleIPVButton(isHidden: Bool, titled: String?, color: UIColor?, titleColor: UIColor?) {
        if let title = titled {
            ipvButton.setTitle(title, for: .normal)
        }
        if let color = color {
            ipvButton.backgroundColor = color
        }
        if let titleColor = titleColor {
            ipvButton.setTitleColor(titleColor, for: .normal)
        }
        ipvButton.isHidden = isHidden
    }
    
    func addEntry(_ entry: String?, titled: String?, image: UIImage?) {
        let entryStackView = UIStackView()
        entryStackView.axis = .vertical
        entryStackView.spacing = 8
        entryStackView.distribution = .fillEqually
        
        let header = UILabel()
        header.text = titled?.uppercased() ?? ""
        header.textColor = RMBTColorManager.textColor.withAlphaComponent(0.5)
        header.font = header.font.withSize(11)
        entryStackView.addArrangedSubview(header)
        
        let body = UIStackView()
        body.axis = .horizontal
        
        if let image = image {
            let imageView = UIImageView(frame: CGRect(0, 0, 16, 16))
            let widthC = NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 16)
            imageView.addConstraint(widthC)
            imageView.image = image
            imageView.contentMode = .scaleAspectFit
            body.spacing = 8
            body.addArrangedSubview(imageView)
        }
        
        if let entry = entry {
            let entryLabel = UILabel()
            entryLabel.text = entry
            entryLabel.textColor = RMBTColorManager.textColor
            entryLabel.font = entryLabel.font.withSize(12)
            body.addArrangedSubview(entryLabel)
        }

        entryStackView.addArrangedSubview(body)

        detailsStackView?.addArrangedSubview(entryStackView)
    }
}
