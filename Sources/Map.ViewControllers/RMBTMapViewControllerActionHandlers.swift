//
//  RMBTMapViewControllerActionHandlers.swift
//  RMBT
//
//  Created by Polina on 27.09.2021.
//  Copyright © 2021 SPECURE GmbH. All rights reserved.
//

import UIKit
import MapboxMaps

protocol RMBTMapViewControllerDelegate {
    func setOperator(_ op: RMBTMapOperator)
    func setDate(_ date: RMBTMapDate)
}

extension RMBTMapViewController: RMBTMapViewControllerDelegate {
    func setOperator(_ op: RMBTMapOperator) {
        if selectedOperator.name != op.name {
            selectedOperator = op
        }
    }
    
    func setDate(_ date: RMBTMapDate) {
        if selectedDate.date != date.date {
            selectedDate = date
        }
    }
    
    @objc func searchFieldDidChange() {
        guard let query = searchField.text, query.count > 0 else {
            dropdown.hide()
            return
        }
        self.httpService.getLocationsFromQuery(query: query) { [weak self] features in
            DispatchQueue.main.async {
                if features.count > 0, let dropdown = self?.dropdown {
                    self?.searchResults = features
                    dropdown.dataSource = features.map({ feature in
                        return feature.title
                    })
                    dropdown.show()
                }
            }
        }
    }
    
    @objc func showOperatorSheet() {
        openBottomSheet(with: .operators, title: L("map.title.operators"), height: RMBTMapDetailsRow.height * CGFloat(operators.count + 1))
    }
    
    @objc func showDateSheet() {
        openBottomSheet(with: .dates, title: L("map.title.history"), height: 180)
    }
    
    @objc func showDetailsSheet(sender: UITapGestureRecognizer) {
        unfocusSearchField()
        selectedFeatureDetails = []
        let spot = sender.location(in: mapView)
        mapView.mapboxMap.queryRenderedFeatures(at: spot, options:RenderedQueryOptions(layerIds: [selectedLayerId], filter: nil), completion: { [weak self] result in
            if let features = try? result.get(), let feature = features.first {
                self?.getFeatureDetails(feature)

                if let featureCount = self?.selectedFeatureDetails.count, featureCount > 1, let camera = self?.mapView.mapboxMap.camera(for: feature.feature.geometry!, padding: .zero, bearing: 0, pitch: 0) {
                    self?.mapView.mapboxMap.setCamera(to: CameraOptions(center: camera.center, zoom: self?.mapView.cameraState.zoom ?? 0))
                    self?.openBottomSheet(with: .details, title: L("map.title.details"), height: RMBTMapDetailsRow.height * CGFloat(featureCount + 1)) // Height including the header row
                }
            }
        })
    }
    
    @objc func switchTechnology(sender: RMBTMapTechnologyButton?) {
        unfocusSearchField()
        guard let button = sender else {
            return
        }
        if selectedTech.label != button.technology.label {
            selectedTech = button.technology
        } else {
            toggleFiltersView()
        }
    }

    @objc func toggleFiltersView() {
        isFiltersViewOpen = !isFiltersViewOpen
    }
    
    @objc func unfocusSearchField() {
        searchField.endEditing(true)
    }
    
    private func getFeatureDetails(_ feature: QueriedFeature) {
        if let name = feature.feature.properties?["NAME"]??.rawValue as? String {
            var label: String?
            if config.mapRegionalPrefix(by: mapView.mapboxMap.cameraState.zoom) == .municipality {
                label = L("map.popup.municipality")
            } else if config.mapRegionalPrefix(by: mapView.mapboxMap.cameraState.zoom) == .county {
                label = L("map.popup.county")
            }
            if label != nil {
                selectedFeatureDetails.append(
                    RMBTMapDetailsRow(label: label!, value: name)
                )
            }
        }
        
        if let count = feature.feature.properties?[getPropertyKey(with: "COUNT")]??.rawValue as? Double {
            selectedFeatureDetails.append(
                RMBTMapDetailsRow(label: L("map.popup.count"), value: "\(Int(count))")
            )
        }

        if let download = feature.feature.properties?[getPropertyKey(with: "DOWNLOAD")]??.rawValue as? Double {
            selectedFeatureDetails.append(
                RMBTMapDetailsRow(
                    label: L("map.popup.download"),
                    value: getPropertyRoundedValue(download, units: L("test.speed.unit") )
                )
            )
        }
        
        if let upload = feature.feature.properties?[getPropertyKey(with: "UPLOAD")]??.rawValue as? Double {
            selectedFeatureDetails.append(
                RMBTMapDetailsRow(
                    label: L("map.popup.upload"),
                    value: getPropertyRoundedValue(upload, units: L("test.speed.unit") )
                )
            )
        }
        
        if let ping = feature.feature.properties?[getPropertyKey(with: "PING")]??.rawValue as? Double {
            selectedFeatureDetails.append(
                RMBTMapDetailsRow(
                    label: L("map.popup.ping"),
                    value: getPropertyRoundedValue(ping, units: "ms" )
                )
            )
        }
    }
    
    
    private func getPropertyKey(with suffix: String) -> String {
        return "\(selectedDate.code)-\(selectedTech.name)-\(selectedOperator.name)-\(suffix)"
    }
    
    private func getPropertyRoundedValue(_ value: Double, units: String) -> String {
        return "\( String(format: "%g", round(value * 10) / 10) ) \( units )"
    }
    
    private func openBottomSheet(with visibleView: RMBTMapBottomSheetView, title: String, height: CGFloat) {
        unfocusSearchField()
        guard let vc = UIStoryboard.mapBottomSheet() as? RMBTMapBottomSheetViewController else {
            return
        }
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        vc.selectedDate = selectedDate
        vc.selectedOperator = selectedOperator
        vc.selectedFeatureDetails = selectedFeatureDetails
        vc.operators = operators
        vc.sheetHeight = height
        vc.sheetTitle = title
        vc.visibleView = visibleView
        self.present(vc, animated: false)
    }
}
