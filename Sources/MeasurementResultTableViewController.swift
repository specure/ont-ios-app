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
import UIKit
import CoreLocation
import RMBTClient

///
class MeasurementResultTableViewController: UITableViewController {

    ///
    var measurementUuid: String?

    ///
    var qosResultsAvailable = false

    ///
    var measuredNow = false

    ///
    var fromMap = false

    ///
    var speedMeasurementResult: SpeedMeasurementResultResponse?

    ///
    var qosMeasurementResult: QosMeasurementResultResponse?

    ///
    var staticMapImage: UIImage?

    ///
    var qosSuccessPercentageString: String?

    ///
    var coordinates: CLLocationCoordinate2D?

    ///
    //var reverseGeocodeAddressString: String?

    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let nc = self.navigationController {
            nc.topViewController!.navigationItem.title = L("RMBT-NI-RESULT")
        }
        
        self.refreshControl?.beginRefreshing()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        if !measuredNow { // hide 'run again' if we got here from the history
            navigationItem.setRightBarButton(nil, animated: false)
        }

        if let uuid = measurementUuid {
            loadSpeedMeasurement(uuid)

            if qosResultsAvailable {
                loadQosMeasurement(uuid)
            }
        }
    }

    ///
    @IBAction func runAgain() {
        logger.debug("run again")

//        if let measurementViewController = navigationController!.viewControllers[navigationController!.viewControllers.count - 1] as? NKOMMeasurementVC {
//            measurementViewController.runAgain = true
//
//            _ = navigationController?.popViewController(animated: true)
//        }
//
        if let startViewController = self.storyboard?.instantiateViewController(withIdentifier: "measurement_view_controller_new") as? NKOMMeasurementVC {
            
            startViewController.runAgain = true
            navigationController?.setViewControllers([startViewController], animated: true)
        
        }
    }

    /// load speed measurement
    private func loadSpeedMeasurement(_ uuid: String) {
        MeasurementHistory.sharedMeasurementHistory.getMeasurement(uuid, success: { response in
            logger.info("Speed measurement with uuid \(uuid) was loaded sucessfully")

            self.speedMeasurementResult = response

            // check if we have coordinates for reverse geo coding
            /*if let lat = self.speedMeasurementResult?.latitude, lon = self.speedMeasurementResult?.longitude {
                self.coordinates = CLLocationCoordinate2D(latitude: lat, longitude: lon)

                GMSGeocoder().reverseGeocodeCoordinate(self.coordinates!, completionHandler: { response, error in
                    self.reverseGeocodeAddressString = response?.firstResult()?.thoroughfare // TODO

                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                    }
                })
            }*/

            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }

            // load static map image
            if let lat = self.speedMeasurementResult?.latitude, let lon = self.speedMeasurementResult?.longitude {

                let s = self.tableView(self.tableView, heightForRowAt: IndexPath(row: 1, section: 4))
                
                let mapWidth = Int(self.tableView.bounds.width * self.tableView.contentScaleFactor)
                let mapHeight = Int(s * self.tableView.contentScaleFactor)
                // Int(self.tableView(self.tableView, heightForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 4)) * self.tableView.contentScaleFactor)

                logger.debug("mapWidth: \(mapWidth), mapHeight: \(mapHeight)")

                StaticMap.getStaticMapImageWithCenteredMarker(lat, lon: lon, width: mapWidth, height: mapHeight, zoom: 15, markerLabel: "Measurement", completionHandler: { [weak self](image) in
                    self?.staticMapImage = image
                    self?.tableView.reloadData()
                })

                DispatchQueue.main.async {
                    self.tableView.reloadSections(NSIndexSet(index: 4) as IndexSet, with: .none) // reload only map section
                    //self.tableView.reloadData()
                }
            }

        }, error: { error in

            // TODO: handle error
            _ = UIAlertController.presentErrorAlert(error as NSError, dismissAction: ({ _ in
                _ = self.navigationController?.popViewController(animated: true)
            }))
        })
    }

    /// load qos measurement
    private func loadQosMeasurement(_ uuid: String) {
        MeasurementHistory.sharedMeasurementHistory.getQosMeasurement(uuid, success: { response in
            logger.info("Qos measurement with uuid \(uuid) was loaded sucessfully")

            self.qosMeasurementResult = response
            self.calculateQosSuccessPercentage()

            //self.tableView.reloadSections(NSIndexSet(index: 3), withRowAnimation: .None) // reload only qos section
            self.tableView.reloadData()

        }, error: { _ in
            // TODO: handle error
        })
    }

    /// calculate success/failure percentage
    private func calculateQosSuccessPercentage() {
        var successCount = 0

        if let testResultDetail = qosMeasurementResult?.testResultDetail, testResultDetail.count > 0 {
            for result in testResultDetail {
                if let failureCount = result.failureCount, failureCount == 0 {
                    successCount += 1
                }
            }

            let percentage = 100 * successCount/testResultDetail.count
            qosSuccessPercentageString = String(format: "%i%% (%i/%i)", percentage, successCount, testResultDetail.count)

            logger.info("QOS INFO: \(String(describing: qosSuccessPercentageString))")
        } else {
            logger.error("NO QOS testResultDetail")
        }
    }

    ///
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show_result_details" {
            if let resultDetailsViewController = segue.destination as? MeasurementResultDetailsTableViewController {
                resultDetailsViewController.measurementUuid = measurementUuid // TODO: save details into object (that we don't have to make a request each time)
            }
        } else if segue.identifier == "show_qos_results" {
            if let qosMeasurementIndexTableViewController = segue.destination as? QosMeasurementIndexTableViewController {
                qosMeasurementIndexTableViewController.qosMeasurementResult = qosMeasurementResult
            }
        } else if segue.identifier == "show_result_on_map" {
            if let nc = segue.destination as? UINavigationController {
                if let mapViewController = nc.topViewController as? RMBTMapViewController {
                    if let lat = speedMeasurementResult?.latitude, let lon = speedMeasurementResult?.longitude {
                        //mapViewController.hidesBottomBarWhenPushed = true
                        mapViewController.initialLocation = CLLocation(latitude: lat, longitude: lon)
                    }
                    mapViewController.isModal = true
                }
            }
            
        }
    }

    ///
    internal func sectionShouldBeHidden(_ section: Int) -> Bool {
        if section == 3 && qosMeasurementResult == nil { // hide qos if there are no results
            return true
        }

        if section == 4 && (speedMeasurementResult?.latitude == nil || speedMeasurementResult?.longitude == nil) { // hide map if there are no coordinates
            return true
        }

        return false
    }
}

// MARK: UITableViewDataSource

extension MeasurementResultTableViewController {

    ///
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if sectionShouldBeHidden(section) {
            return nil
        }

        switch section {
        case 0:
            var measurementHeader = L("history.result.headline.measurement")
            if let timeString = speedMeasurementResult?.timeString {
                measurementHeader += " - " + timeString
            }
            return measurementHeader
        case 1: return L("history.result.headline.network")
        case 2: return L("history.result.headline.details")
        case 3: return L("history.result.headline.qos")
        case 4:
            var mapHeader = L("history.result.headline.map")
            if let location = speedMeasurementResult?.location {
                mapHeader += " - " + location
            }
            return mapHeader
        default: return "-unknown section-"
        }
    }

    ///
    override func numberOfSections(in tableView: UITableView) -> Int {
        /*var*/let sections = 5

        // TODO
        //if speedMeasurementResult?.latitude == nil || speedMeasurementResult?.longitude == nil {
        //    sections -= 1 // hide map
        //}

        return sections
    }

    ///
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sectionShouldBeHidden(section) {
            return 0
        }

        switch section {
        case 0: return speedMeasurementResult?.classifiedMeasurementDataList?.count ?? 0
        case 1: return speedMeasurementResult?.networkDetailList?.count ?? 0
        case 2: return 2
        case 3: return 2
        case 4: return 1
        default: return 0
        }
    }

    ///
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // default cell
        if let cell = tableView.dequeueReusableCell(withIdentifier: "key_value_cell") {
        
            switch indexPath.section {
            case 0: // Measurement info
                
                // no classification for nkom...
                
                //if let classifiedMeasurementDataList = speedMeasurementResult?.classifiedMeasurementDataList where classifiedMeasurementDataList.count >= indexPath.row {
                //    let classifiedData = classifiedMeasurementDataList[indexPath.row] // TODO: why is this not an optional? -> need to guard with "where" in if-let
                
                if let classifiedData = speedMeasurementResult?.classifiedMeasurementDataList?[indexPath.row] {
                    
                    cell.textLabel?.text = classifiedData.title
                    cell.detailTextLabel?.text = classifiedData.value
                    
                    //cell.classification = classifiedData.classification
                    
                    cell.accessoryType = .none
                }
                
                return cell
                
            case 1: // Network info
                
                //let cell = tableView.dequeueReusableCellWithIdentifier("key_value_cell") as! KeyValueTableViewCell
                
                //if let networkDetailList = speedMeasurementResult?.networkDetailList where networkDetailList.count >= indexPath.row {
                //    let networkDetail = networkDetailList[indexPath.row] // TODO: why is this not an optional? -> need to guard with "where" in if-let
                
                if let networkDetail = speedMeasurementResult?.networkDetailList?[indexPath.row] {
                    
                    cell.textLabel?.text = networkDetail.title
                    cell.detailTextLabel?.text = networkDetail.value
                    
                    cell.accessoryType = .none
                }
                
                return cell
                
            case 2: // Measurement details
                
                //let cell = tableView.dequeueReusableCellWithIdentifier("key_value_cell") as! KeyValueTableViewCell
                
                if indexPath.row == 0 {
                    cell.textLabel?.text = L("history.result.time")
                    cell.detailTextLabel?.text = speedMeasurementResult?.timeString
                    
                    cell.accessoryType = .none
                } else if indexPath.row == 1 {
                    cell.textLabel?.text = L("history.result.more-details")
                    cell.detailTextLabel?.text = nil
                    
                    cell.accessoryType = .disclosureIndicator
                }
                
                return cell
                
            case 3: // QOS results
                
                //let cell = tableView.dequeueReusableCellWithIdentifier("key_value_cell") as! KeyValueTableViewCell
                
                if indexPath.row == 0 {
                    cell.textLabel?.text = L("history.result.qos.results")
                    cell.detailTextLabel?.text = qosSuccessPercentageString
                    
                    cell.accessoryType = .none
                } else if indexPath.row == 1 {
                    cell.textLabel?.text = L("history.result.qos.results-detail")
                    cell.detailTextLabel?.text = nil
                    
                    cell.accessoryType = .disclosureIndicator
                }
                
                return cell
                
            case 4: // Map
                if speedMeasurementResult?.latitude != nil, speedMeasurementResult?.longitude != nil {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "map_cell") as! MeasurementResultMapTableViewCell
                    
                    //cell.coordinateStringLabel?.text = speedMeasurementResult?.location
                    
                    /*if let rcas = reverseGeocodeAddressString {
                     cell.coordinateStringLabel?.text = cell.coordinateStringLabel!.text! + "\n" + rcas
                     }*/
                    
                    cell.staticMapImageView?.image = staticMapImage
                    return cell
                } else {
                    //let cell = tableView.dequeueReusableCellWithIdentifier("key_value_cell") as! KeyValueTableViewCell
                    
                    cell.textLabel?.text = ""
                    cell.detailTextLabel?.text = "No coordinates (TODO)"
                    
                    cell.accessoryType = .none
                    
                    return cell
                }
                
            default:
                assert(false, "section \(indexPath.section) is not configured")
                return UITableViewCell()
            }
        }
        return UITableViewCell()
    }
}

// MARK: UITableViewDelegate

///
extension MeasurementResultTableViewController {

    ///
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if sectionShouldBeHidden(section) {
            return 0.0
        }

        if section == 0 {
            return 44
        }

        return 35
    }

    ///
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //
        let defaultHeight: CGFloat = 44
        let extendedHeight: CGFloat = 200
        
        if indexPath.section == 4, speedMeasurementResult?.latitude != nil,  speedMeasurementResult?.longitude != nil {
            return extendedHeight
        } else {
            return defaultHeight
        }
    }

    ///
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return
            indexPath.section == 2 && indexPath.row == 1 ||
            indexPath.section == 3 && indexPath.row == 1 ||
            indexPath.section == 4
    }

    ///
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 2:
            if indexPath.row == 1 { // result details tapped
                performSegue(withIdentifier: "show_result_details", sender: nil)
            }
        case 3: // qos tapped
            if indexPath.row == 1 {
                performSegue(withIdentifier: "show_qos_results", sender: nil)
            }
        case 4: // map tapped
            if speedMeasurementResult?.latitude != nil, speedMeasurementResult?.longitude != nil { // prevent map segue if we don't have coordinates
                if fromMap {
                    // we come from global map view -> just go back to map
                    _ = navigationController?.popViewController(animated: true)
                } else {
                    performSegue(withIdentifier: "show_result_on_map", sender: nil)
                }
            }
        default: break
        }
    }
}
