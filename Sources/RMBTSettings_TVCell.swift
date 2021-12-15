//
//  RMBTSettingsTVCell.swift
//  RMBT
//
//  Created by Tomas Baculák on 21/12/2016.
//  Copyright © 2016 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTSettingsTVCell: UITableViewCell {
    
    @IBOutlet var itemLabel: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let label = itemLabel {
            label.formatStringsSetting(tag)
        }
    }
}
