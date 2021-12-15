//
//  RMBTTestTableViewCell.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 6/29/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit
import QuartzCore

class RMBTTestTableViewCell: UITableViewCell {

    struct RMBTTestModelView {
        let item: RMBTTestViewController.RMBTTestState
        
        var value: String? {
            if item.identifier == "qos",
                item.progress > 0 {
                return String(format: "%0.0f%%", item.progress * 100)
            }
            if let currentValue = item.currentValue,
                currentValue != "-" {
                if item.identifier == "ping" {
                    return RMBTMillisecondsStringWithNanos(UInt64((currentValue as NSString).longLongValue))
                } else if item.identifier == "download" || item.identifier == "upload" {
                    return RMBTSpeedMbpsString(Double(currentValue) ?? 0.0, withMbps: true)
                } else if item.identifier == "packet_lose" {
                    var value = currentValue
                    return value.addPercentageString()
                } else if item.identifier == "jitter" {
                    var value = RMBTMillisecondsString(UInt64((currentValue as NSString).longLongValue))
                    return value.addMsString()
                }
                
            }
            return item.currentValue ?? "-"
        }
        
        var title: String? {
            return item.title
        }
        
        var isLoading: Bool { return item.progress > 0.0 && item.progress < 1.0}
        
        var isDone: Bool { return item.progress >= 1.0 }
        
        init(item: RMBTTestViewController.RMBTTestState) {
            self.item = item
        }
    }
    
    static let ID = "RMBTTestTableViewCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var activityIndicator: RMBTActivityIndicator?
    @IBOutlet weak var checkMarkImageview: UIView?
    
    private var activatedColor: UIColor = .black
    private var inactiveColor: UIColor = .gray
    
    var testModelView: RMBTTestModelView? {
        didSet {
            self.titleLabel.text = testModelView?.title
            self.valueLabel.text = testModelView?.value

            self.titleLabel.textColor = testModelView?.isLoading == true || testModelView?.isDone == true ? activatedColor : inactiveColor
            self.valueLabel.textColor = testModelView?.isLoading == true || testModelView?.isDone == true ? activatedColor : inactiveColor

            self.activityIndicator?.isHidden = testModelView?.isLoading == false
            self.checkMarkImageview?.isHidden = testModelView?.isLoading == true
        }
    }
    
    deinit {
        if let activityIndicator = self.activityIndicator as? RMBTActivityIndicator {
            activityIndicator.stopAnimation()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard UIApplication.shared.applicationState == .inactive else {
            return
        }
        
        self.applyColorScheme()
    }
    
    func applyColorScheme() {
        self.activityIndicator?.imageView.tintColor = RMBTColorManager.tintLightColor
    }
    
}
