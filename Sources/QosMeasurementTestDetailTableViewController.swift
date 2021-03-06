/*****************************************************************************************************
 * Copyright 2014-2016 SPECURE GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *****************************************************************************************************/

import Foundation
import RMBTClient

///
struct QosMeasurementTestEvaluationItem {

    ///
    var evaluationMessage: String

    ///
    var success: Bool
}

///
class QosMeasurementTestDetailTableViewController: UITableViewController {

    ///
    var qosMeasurementResult: QosMeasurementResultResponse?

    ///
    var qosMeasurementTestItem: QosMeasurementTestItem?

    ///
    var evaluationItems = [QosMeasurementTestEvaluationItem]()

    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = qosMeasurementTestItem?.title
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        if let testResultDetailDescription = qosMeasurementResult?.testResultDetailDescription {
            evaluationItems.append(
                contentsOf: testResultDetailDescription.filter({ item in
                    if let oldUid = qosMeasurementTestItem?.oldUid, let uidList = item.uid {
                        return uidList.contains(oldUid)
                    }

                    return false
                }).map({ item in
                    if let description = item.description, let status = item.status {
                        return QosMeasurementTestEvaluationItem(evaluationMessage: description, success: status == "ok")
                    }

                    assert(false, "Should never happen")
                    return QosMeasurementTestEvaluationItem(evaluationMessage: "-", success: false)
                })
            )
        }

        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
        tableView.reloadData()
        
        if UIDevice.isDeviceTablet() {
            self.addStandardBackButton()
        }
    }
    
    @objc override func popAction() {
        if let tabBarController = UIApplication.shared.delegate?.tabBarController() {
            tabBarController.pop()
        } else {
            super.popAction()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard UIApplication.shared.applicationState == .inactive else {
            return
        }
        
        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
        self.tableView.reloadData()
    }
    
    func applyColorScheme() {
        self.view.backgroundColor = RMBTColorManager.background
        self.tableView.backgroundColor = RMBTColorManager.tableViewBackground
        self.tableView.separatorColor = RMBTColorManager.tableViewSeparator
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func applyColorScheme(for cell: UITableViewCell) {
        cell.backgroundColor = RMBTColorManager.cellBackground
        cell.textLabel?.textColor = RMBTColorManager.tintColor
        cell.detailTextLabel?.textColor = RMBTColorManager.textColor
    }

    // TODO:
    ///
    //private func getTextHeight() -> CGFloat {
    //    let textRect: CGRect = (detailTestText as NSString).boundingRectWithSize(CGSize(width: Double(view.frame.width), height: DBL_MAX),
    //                                                                             options: .UsesLineFragmentOrigin, attributes: nil, context: nil)
    //
    //    return max(textRect.height + 20, 350)
    //}
}

// MARK: UITableViewDataSource

extension QosMeasurementTestDetailTableViewController {

    ///
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var title: String? = nil
        switch section {
        case 0: title = "Description"
        case 1: title = "Evaluation"
        case 2: title = "Details"
        default: title = "-"
        }
        let header = RMBTSettingsTableViewHeader.view()
        header?.titleLabel.text = title
        header?.applyColorScheme()
        return header
    }

    ///
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return evaluationItems.count
        }

        return 1
    }

    ///
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "qos_detail_description")!

            cell.textLabel?.text = qosMeasurementTestItem?.summary
            cell.selectionStyle = .none
            self.applyColorScheme(for: cell)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "qos_detail_messages")!
            // TODO
            self.applyColorScheme(for: cell)
            let item = evaluationItems[indexPath.row]

            cell.textLabel?.text = item.evaluationMessage
            cell.contentView.backgroundColor = item.success ? RMBT_CHECK_CORRECT_COLOR : RMBT_CHECK_INCORRECT_COLOR
            cell.textLabel?.textColor = .white
            cell.selectionStyle = .none
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "qos_detail_text") as! QosMeasurementResultDescriptionTableViewCell

            cell.descriptionTextView?.text = qosMeasurementTestItem?.testDescription
            cell.selectionStyle = .none
            cell.applyColorScheme()
            return cell
        default:
            assert(false, "Should never happen")
            return UITableViewCell()
        }
    }
}

// MARK: UITableViewDelegate

///
extension QosMeasurementTestDetailTableViewController {

    ///
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }

    ///
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 80
        case 2: return 200 // TODO: calculate height
        default: return 44
        }
    }
}
