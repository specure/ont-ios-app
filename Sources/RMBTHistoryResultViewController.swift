//
//  RMBTHistoryResultViewController.swift
//  RMBT
//
//  Created by Benjamin Pucher on 23.09.14.
//  Copyright © 2014 SPECURE GmbH. All rights reserved.
//

import Foundation
import CoreLocation
import TUSafariActivity

///
class RMBTHistoryResultViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private class RMBTExpandableHistoryResultItem: RMBTHistoryResultItem {
        enum Identifier {
            case downloadGraph
            case uploadGraph
        }
        
        var isExpanded: Bool = false
        var identifier: Identifier = .downloadGraph
    }
    
    ///
    @IBOutlet var tableView: UITableView!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return RMBTColorManager.statusBarStyle
    }
    
    ///
    var historyResult: RMBTHistoryResult? {
        didSet {
            self.updateMeasurementItems()
            if self.isViewLoaded {
                self.reloadData()
            }
        }
    }
    
    var measurementItems: [RMBTHistoryResultItem] = []

    ///
    var isModal = false

    
    ///
//    var qosResults: QosMeasurementResultResponse?

    func updateMeasurementItems() {
        guard let historyResult = historyResult else { return }
        
        var measurementItems: [RMBTHistoryResultItem] = []
        
        for item in historyResult.measurementItems {
            measurementItems.append(item)
            if item.title == "history.header.download",
               historyResult.historySpeedGraph != nil {
                let expandableItem = RMBTExpandableHistoryResultItem()
                expandableItem.identifier = .downloadGraph
                measurementItems.append(expandableItem)
            }
            if item.title == "history.header.upload",
               historyResult.historySpeedGraph != nil {
                let expandableItem = RMBTExpandableHistoryResultItem()
                expandableItem.identifier = .uploadGraph
                measurementItems.append(expandableItem)
            }
        }
        
        self.measurementItems = measurementItems
    }
    
    @IBAction func share(_ sender: Any) {
        var activities = [UIActivity]()
        var items = [AnyObject]()

        if let shareText = historyResult?.shareText {
            items.append(shareText as AnyObject)
        }

        if let shareURL = historyResult?.shareURL {
            items.append(shareURL as AnyObject)
            activities.append(TUSafariActivity())
        }

        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: activities)
        activityViewController.setValue(RMBTAppTitle(), forKey: "subject")

        if let popover = activityViewController.popoverPresentationController {
            if let shareView = sender as? UIView {
                popover.sourceView = shareView
                popover.sourceRect = shareView.bounds
            } else if let shareView = sender as? UIBarButtonItem {
                popover.barButtonItem = shareView
            }
        }
        present(activityViewController, animated: true, completion: nil)
    }

// MARK: - Object Life Cycle

    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(cell: "RMBTHistorySpeedGraphCell")
        self.navigationItem.formatHistoryResultPageTitle()
        self.reloadData()
        
        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
        
        if UIDevice.isDeviceTablet() {
            self.addStandardBackButton()
        }
    }
    
    func reloadData() {
        if let historyResult = self.historyResult {
            historyResult.ensureBasicDetails {
                assert(historyResult.dataState != .index, "Result not filled with basic data")
                self.updateMeasurementItems()
                self.tableView.reloadData()
                historyResult.ensureGraphs {
                    self.updateMeasurementItems()
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard UIApplication.shared.applicationState == .inactive else {
            return
        }
        
        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
    }
    
    func applyColorScheme() {
        self.view.backgroundColor = RMBTColorManager.background
        self.tableView.backgroundColor = RMBTColorManager.tableViewBackground
        self.tableView.separatorColor = RMBTColorManager.tableViewSeparator
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    ///
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: false)
        //
        if isModal { addStandardDoneButton() }
    }
    
    func expandIfNeeded(at indexPath: IndexPath) {
        let item = measurementItems[indexPath.row]
        if let item = item as? RMBTExpandableHistoryResultItem {
            item.isExpanded = false
        } else {
            if item.title == "history.header.download",
               indexPath.row + 1 < measurementItems.count,
               let graphItem = measurementItems[indexPath.row + 1] as? RMBTExpandableHistoryResultItem {
                graphItem.isExpanded = !graphItem.isExpanded
            }
            if item.title == "history.header.upload",
               indexPath.row + 1 < measurementItems.count,
               let graphItem = measurementItems[indexPath.row + 1] as? RMBTExpandableHistoryResultItem {
                graphItem.isExpanded = !graphItem.isExpanded
            }
        }
        self.tableView.reloadSections([0], with: .automatic)
    }
    
    func qosResultCell(with indexPath: IndexPath) -> UITableViewCell {
        let cell = RMBTHistoryItemCell(style: .default, reuseIdentifier: "qos_test_cell")
        cell.applyTintColor()
        cell.applyColorScheme()

        if indexPath.row == 0 {
            cell.isUserInteractionEnabled = false
            cell.set(title: L("history.result.qos.results"),
                         subtitle: self.historyResult?.shortQosResultString ?? "")
        } else {
            if let qos = self.historyResult?.qosTestResultCounters,
               qos.count > 0 {
                cell.isUserInteractionEnabled = true
                cell.set(title: L("history.result.qos.results-detail"),
                         subtitle: "",
                         type: .disclosureIndicator)
            } else {
                cell.set(title: "",
                         subtitle: "",
                         type: .none)
                cell.isUserInteractionEnabled = false
                cell.textLabel?.adjustsFontSizeToFitWidth = true
                cell.textLabel?.minimumScaleFactor = 0.6
                cell.textLabel?.numberOfLines = 2
                cell.accessoryType = .none
                logger.debug("QOS RESULTS MISSING")
            }
        }
        
        return cell
    }
    
    func historyResultTimeCell(with indexPath: IndexPath) -> UITableViewCell {
        let cell = RMBTHistoryItemCell(style: .default, reuseIdentifier: "detail_test_cell")
        cell.applyColorScheme()
        if indexPath.row == 0 {
            cell.isUserInteractionEnabled = false
            if let time = self.historyResult?.timeString {
                cell.set(title: L("history.result.time"),
                         subtitle: time)
            } else {
                cell.set(title: L("history.result.time"),
                         subtitle: "")
            }
        } else {
            cell.isUserInteractionEnabled = true
            cell.set(title: L("history.result.more-details"),
                     subtitle: "",
                     type: .disclosureIndicator)
        }
        
        return cell
    }

    @objc override func popAction() {
        if let tabBarController = UIApplication.shared.delegate?.tabBarController() {
            tabBarController.pop()
        } else {
            super.popAction()
        }
    }
// MARK: - UITableViewDataSource/UITableViewDelegate

    //
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let historyResult = historyResult else { return 0 }
        return historyResult.dataState == RMBTHistoryResultDataState.index ? 0 : 4
    }
    
    //
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0,
           let item = self.measurementItems[indexPath.row] as? RMBTExpandableHistoryResultItem {
            return item.isExpanded ? 120 : 0
        }
        return 45
    }
    
    ///
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 2 {
            return self.historyResultTimeCell(with: indexPath)
        } else if indexPath.section == 3 {
            return self.qosResultCell(with: indexPath)
        } else {
            if let item = self.itemsForSection(sectionIndex: indexPath.section)[indexPath.row] as? RMBTExpandableHistoryResultItem {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RMBTHistorySpeedGraphCell", for: indexPath) as! RMBTHistorySpeedGraphCell
                if item.identifier == .downloadGraph {
                    cell.drawSpeedGraph(historyResult?.historySpeedGraph?.downloadThroughputs)
                }
                if item.identifier == .uploadGraph {
                    cell.drawSpeedGraph(historyResult?.historySpeedGraph?.uploadThroughputs)
                }
                return cell
                
            } else if let item = self.itemsForSection(sectionIndex: indexPath.section)[indexPath.row] as? RMBTHistoryResultItem {
                let cell = RMBTHistoryItemCell(style: .default, reuseIdentifier: "history_result")
                cell.applyColorScheme()
                cell.textLabel?.applyResultColor()
                cell.setItem(item: item)
                
                return cell
            }

            return UITableViewCell()
        }
    }

    ///
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return self.itemsForSection(sectionIndex: section).count
        case 1: return self.itemsForSection(sectionIndex: section).count
        case 2: return 2
        case 3: return 2
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var title: String?
        switch section {
        case 0: title = L("history.result.headline.measurement")
        case 1: title = L("history.result.headline.network")
        case 2: title = L("history.result.headline.details")
        case 3: title = L("history.result.headline.qos")
        default: title = "-unknown section-"
        }
        let header = RMBTSettingsTableViewHeader.view()
        header?.titleLabel.text = title
        header?.applyColorScheme()
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }

    ///
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)

        switch indexPath.section {
        case 0: expandIfNeeded(at: indexPath)
        case 2: showResultDetails()
        case 3: showQosResults()
        default: break
        }
    }

// MARK: - Class Methods

    func showQosResults() {
        let qtView = UIStoryboard.qosResultsScreen() as! QosMeasurementIndexTableViewController
        qtView.historyResult = self.historyResult
        if UIDevice.isDeviceTablet(),
            let tabBarController = UIApplication.shared.delegate?.tabBarController() {
            tabBarController.push(vc: qtView, from: self)
        } else {
            self.navigationController?.pushViewController(qtView, animated: true)
        }
    }
    
    func showResultDetails() {
        let rdvc = UIStoryboard.resultDetailsScreen() as! RMBTHistoryResultDetailsViewController
        rdvc.historyResult = self.historyResult
        if UIDevice.isDeviceTablet(),
            let tabBarController = UIApplication.shared.delegate?.tabBarController() {
            tabBarController.push(vc: rdvc, from: self)
        } else {
            self.navigationController?.pushViewController(rdvc, animated: true)
        }
    }
    ///
    private func trafficLightTapped(n: NSNotification) {
        self.presentModalBrowserWithURLString(RMBTConfiguration.RMBT_HELP_RESULT_URL)
    }

    ///
    private func itemsForSection(sectionIndex: Int) -> [AnyObject] {
        assert(sectionIndex <= 5, "Invalid section")
        guard let historyResult = historyResult else { return [] }
        return (sectionIndex == 0) ? measurementItems : historyResult.netItems // !
    }

}

extension RMBTHistoryResult {
    var shortQosResultString: String {
        if let qos = self.qosTestResultCounters,
           qos.count > 0 {
            var successCount = 0
            var totalCount = 0
            for q in qos {
                if let success = q.successCount {
                    successCount += success
                }
                if let total = q.totalCount {
                    totalCount += total
                }
            }
            let percent = Double(successCount) / Double(totalCount) * 100.0
            return "\(Int(percent))% (\(successCount)/\(totalCount))"
        }
        return ""
    }
}
