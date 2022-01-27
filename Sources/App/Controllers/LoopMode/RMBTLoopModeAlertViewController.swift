//
//  RMBTLoopModeAlertViewController.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 11/17/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTLoopModeAlertViewController: TopLevelViewController {

    @IBOutlet weak var heightItemsConstraint: NSLayoutConstraint!
    @IBOutlet weak var itemsTableView: UITableView!
    @IBOutlet weak var footerTextView: UITextView!
    @IBOutlet weak var titleTextView: UITextView!
    
    @IBOutlet weak var agreeButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    var items: [String] = []
    
    var onComplete: () -> Void = {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        declineButton.setTitle(L("RBMT-BASE-DECLINE"), for: .normal)
        declineButton.addTarget(self, action: #selector(decline), for: .touchUpInside)
        agreeButton.setTitle(L("RBMT-BASE-AGREE"), for: .normal)
        agreeButton.addTarget(self, action: #selector(agree), for: .touchUpInside)
        
        self.title = L("loopmode.test.init.title")
        self.itemsTableView.register(cell: RMBTLoopModeAlertCell.ID)
        self.itemsTableView.estimatedRowHeight = 52
        self.itemsTableView.estimatedSectionFooterHeight = 0
        self.itemsTableView.estimatedSectionHeaderHeight = 0
        self.itemsTableView.rowHeight = UITableView.automaticDimension
        self.itemsTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        self.prepareTexts()
        self.prepareItems()
        self.itemsTableView.reloadData()
        self.itemsTableView.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.heightItemsConstraint.constant = self.itemsTableView.contentSize.height
        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
    }
    
    func prepareTexts() {
        let titleFont = UIFont.appRegularFontWith(size: 13)
        let titleColor = RMBTColorManager.tintColor
        
        let textFont = UIFont.appRegularFontWith(size: 13)
        let textColor = RMBTColorManager.loopModeValueColor
        let textColor2 = RMBTColorManager.tintColor
        
        let title = LC("loopmode_alert.activation_privacy") + "<br />"
        let titleDescription = L("loopmode_alert.activation_privacy.description")
        let text = NSMutableAttributedString(attributedString: title.htmlAttributedString(font: titleFont, color: titleColor))
        text.append(titleDescription.htmlAttributedString(font: textFont, color: textColor))
        
        self.titleTextView.attributedText = text
        
        let footerDataUsage = LC("loopmode_alert.data_usage") + "<br />"
        let footerDataUsageDescription = L("loopmode_alert.data_usage.description") + " "
        let footerDataUsageDescription2 = L("loopmode_alert.data_usage.description_2") + "<br /><br />"
        
        let footerBatteryPower = LC("loopmode_alert.battery_power") + "<br />"
        let footerBatteryPowerDescription = L("loopmode_alert.battery_power.description") + " "
        let footerBatteryPowerDescription2 = L("loopmode_alert.battery_power.description_2") + "<br /><br />"
        
        let footerText = NSMutableAttributedString(attributedString: footerDataUsage.htmlAttributedString(font: titleFont, color: titleColor))
        footerText.append(footerDataUsageDescription.htmlAttributedString(font: textFont, color: textColor))
        footerText.append(footerDataUsageDescription2.htmlAttributedString(font: textFont, color: textColor2))
        
        footerText.append(footerBatteryPower.htmlAttributedString(font: titleFont, color: titleColor))
        footerText.append(footerBatteryPowerDescription.htmlAttributedString(font: textFont, color: textColor))
        footerText.append(footerBatteryPowerDescription2.htmlAttributedString(font: textFont, color: textColor2))
        
        self.footerTextView.attributedText = footerText
    }
    
    func prepareItems() {
        var items: [String] = []
        items.append(L("loopmode_alert.items.item_1"))
        items.append(L("loopmode_alert.items.item_2"))
        items.append(L("loopmode_alert.items.item_3"))
        items.append(L("loopmode_alert.items.item_4"))
        items.append(L("loopmode_alert.items.item_5"))
        items.append(L("loopmode_alert.items.item_6"))
        
        self.items = items
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard UIApplication.shared.applicationState == .inactive else {
            return
        }
        
        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
    }
    
    override func applyColorScheme() {
        self.view.backgroundColor = RMBTColorManager.background
        self.itemsTableView.backgroundColor = RMBTColorManager.background
        declineButton.tintColor = RMBTColorManager.textColor
        agreeButton.tintColor = RMBTColorManager.tintColor
    }
    
    @objc func decline(_ sender: Any) {
        RMBTSettings.sharedSettings.debugLoopMode = false
        self.onComplete()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func agree(_ sender: Any) {
        RMBTSettings.sharedSettings.debugLoopMode = true
        self.onComplete()
        self.dismiss(animated: true, completion: nil)
    }
}

extension RMBTLoopModeAlertViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: RMBTLoopModeAlertCell.ID, for: indexPath) as! RMBTLoopModeAlertCell
        cell.titleLabel.text = item
        cell.applyColorScheme()
        return cell
    }
}
