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

extension SpeedMeasurementDetailResultResponse.SpeedMeasurementDetailItem {

    ///
    func convertValueToString() -> String {
        
        if let stringItemValue = self.value as? String {
            return stringItemValue
        } else if let numberItemValue = self.value as? NSNumber {
            return String(describing: numberItemValue)
        }
        
        return ""
    }
}

///
class MeasurementResultDetailsTableViewController: UITableViewController {

    //var detailedT
    var measurementUuid: String?

    ///
    internal var details: [SpeedMeasurementDetailResultResponse.SpeedMeasurementDetailItem]?

    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let nc = self.navigationController {
            nc.topViewController!.navigationItem.title = L("history.result.headline.details")
        }

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        if let uuid = measurementUuid {
            MeasurementHistory.sharedMeasurementHistory.getMeasurementDetails(uuid, success: { response in
                self.details = response.speedMeasurementResultDetailList
                self.tableView.reloadData()
            }, error: { _ in
                // TODO: handle error
            })
        }
    }

    ///
    internal func itemNeedsLargeCell(_ item: SpeedMeasurementDetailResultResponse.SpeedMeasurementDetailItem) -> Bool {
        
        let numberOfChar = UIDevice.isDeviceTablet() ? 100:25
        return (item.title?.count)! > numberOfChar || (item.convertValueToString().count) > numberOfChar
    }
}

// MARK: UITableViewDataSource

extension MeasurementResultDetailsTableViewController {

    ///
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    ///
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return details?.count ?? 0
    }

    ///
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let item = details?[indexPath.row] {

            var cell: UITableViewCell

            if itemNeedsLargeCell(item) {
                cell = tableView.dequeueReusableCell(withIdentifier: "history_result_detail_subtitle")!
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "history_result_detail")!
            }

            cell.textLabel?.text = item.title
            cell.detailTextLabel?.text = item.convertValueToString()

            return cell

        } else {
            assert(false, "wrong indexPath")
            return UITableViewCell()
        }
    }
}

// MARK: UITableViewDelegate

///
extension MeasurementResultDetailsTableViewController {

    ///
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let item = details?[indexPath.row] {
            return UITableViewCell.rmbtApproximateOptimalHeightForText(item.title, detailText: item.convertValueToString())
        }

        return 44
    }
}
