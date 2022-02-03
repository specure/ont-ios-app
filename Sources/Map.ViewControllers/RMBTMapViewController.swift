/*****************************************************************************************************
 * Copyright 2013 appscape gmbh
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

import BCGenieEffect
import RMBTClient
import CoreLocation
import Mapbox
import DropDown

class RMBTMapViewController: TopLevelViewController, MGLMapViewDelegate, UITextFieldDelegate {
    let httpService = RMBTMapHttpService()
    let dropdown = DropDown()
    var mapView: MGLMapView!
    var config: RMBTConfigurationProtocol!
    var searchResults: [RMBTGeocodingFeature] = []
    var isFiltersViewOpen = false {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.rearrangeWidgets()
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @IBOutlet weak var filtersView: UIView!
    @IBOutlet weak var filtersViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var technologiesView: UIStackView!
    @IBOutlet weak var miniTechnologiesView: UIStackView!
    @IBOutlet weak var selectedOperatorLabel: UILabel!
    @IBOutlet weak var infoIcon: UIImageView!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var selectedOperatorButton: UIButton!
    @IBOutlet weak var selectedDateButton: UIButton!
    @IBOutlet weak var disclaimer: UILabel!
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return RMBTColorManager.statusBarStyle }
    override var shouldAutorotate: Bool { return true }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .all }
    
    var selectedRegionalPrefix = RMBTMapRegionalPrefix.county {
        didSet {
            switchVisibleLayer()
        }
    } // Which regional unit we show depending on the zoom level
    var selectedDate = RMBTMapDate.list[1] {
        didSet {
            selectedDateButton.setTitle(selectedDate.monthNameAndYear, for: .normal)
            switchVisibleLayer()
        }
    }
    var selectedTech = RMBTMapTechnology.list.first! {
        didSet {
            technologiesView.subviews.forEach({ subview in
                if let techButton = subview as? RMBTMapTechnologyButton, let techButtonLabel = techButton.title(for: .normal) {
                    techButton.colorizeIf(selectedTech.label == techButtonLabel, color: selectedTech.color)
                }
            })
            initMiniTechnologies()
            DispatchQueue.main.async {
                self.switchVisibleLayer()
            }
        }
    }
    var selectedOperator = RMBTMapOperator.list.first! {
        didSet {
            selectedOperatorButton.setTitle(selectedOperator.longLabel, for: .normal)
            selectedOperatorLabel.text = selectedOperator.longLabel
            DispatchQueue.main.async {
                self.switchVisibleLayer()
            }
        }
    }
    var selectedFeatureDetails: [ RMBTMapDetailsRow ] = []
    var operators = RMBTMapOperator.list
    
    // Which layer we show depending on the selected params
    var selectedLayerId: String {
        return "\(selectedRegionalPrefix.rawValue)-\(selectedDate.code)-\(selectedTech.name)-\(selectedOperator.name)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.tabBarItem.title = L("tabbar.title.map")
        self.tabBarItem.image = UIImage(named: "ic_map_white_25pt")
        self.navigationController?.tabBarItem = self.tabBarItem
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.updateColorForNavigationBarAndTabBar()
        
        config = RMBTConfiguration
        initMap()
        initSearchField()
        initSearchDropdown()
        initFiltersView()
        initTechnologies()
        initMiniTechnologies()
        initOperators()
        initDates()
        initDetails()
        rearrangeWidgets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateColorForNavigationBarAndTabBar()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        unfocusSearchField()
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        switchVisibleLayer()
    }
    
    func mapView(_ mapView: MGLMapView, regionDidChangeWith reason: MGLCameraChangeReason, animated: Bool) {
        let prevRegionalPrefix = self.selectedRegionalPrefix
        let newRegionalPrefix = config.mapRegionalPrefix(by: mapView.zoomLevel)
        if prevRegionalPrefix != newRegionalPrefix {
            self.selectedRegionalPrefix = newRegionalPrefix
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func initMap() {
        mapView = MGLMapView(frame: view.bounds, styleURL: URL(string: config.RMBT_MAPBOX_BASIC_STYLE_URL))
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(CLLocationCoordinate2D(latitude: config.RMBT_MAP_INITIAL_LAT, longitude: config.RMBT_MAP_INITIAL_LNG), zoomLevel: Double(config.RMBT_MAP_INITIAL_ZOOM), animated: false)
        mapView.delegate = self
        mapView.maximumZoomLevel = 15
        view.addSubview(mapView)
    }
    
    private func initSearchField() {
        searchField.placeholder = L("map.search")
        searchField.addTarget(self, action: #selector(searchFieldDidChange), for: .editingChanged)
        searchField.delegate = self
        view.bringSubviewToFront(searchField)
    }
    
    private func initSearchDropdown() {
        dropdown.anchorView = searchField
        dropdown.layer.zPosition = 11
        dropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            if searchResults.count > index {
                let location = searchResults[index]
                if let bounds = location.mapView {
                    let sw = CLLocationCoordinate2D(latitude: bounds.south, longitude: bounds.west)
                    let ne = CLLocationCoordinate2D(latitude: bounds.north, longitude: bounds.east)
                    mapView.setVisibleCoordinateBounds( MGLCoordinateBounds(sw: sw, ne: ne), animated: true)
                } else {
                    let position = location.position
                    let center = CLLocationCoordinate2D(latitude: position.lat, longitude: position.lng)
                    mapView.setCenter(center, zoomLevel: mapView.zoomLevel, animated: true)
                }
                searchField.text = item
                unfocusSearchField()
            }
            dropdown.hide()
        }
        dropdown.bottomOffset = CGPoint(x: 0, y: (dropdown.anchorView?.plainView.bounds.height)! + 8)
        dropdown.cornerRadius = 8
        dropdown.backgroundColor = UIColor.white
        dropdown.separatorColor = UIColor.lightGray
        dropdown.customCellConfiguration = { (index, item, cell) in
            cell.separatorInset = .zero
        }
    }
    
    private func initFiltersView() {
        filtersView.layer.shadowColor = UIColor.black.cgColor
        filtersView.layer.shadowRadius = 8
        filtersView.layer.shadowOpacity = 0.25
        filtersView.layer.shadowOffset = CGSize(width: 0, height: 2)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleFiltersView))
        filtersView.addGestureRecognizer(tapGesture)
        
        view.bringSubviewToFront(filtersView)
        
        disclaimer.text = L("map.disclaimer")
    }
    
    private func initTechnologies() {
        RMBTMapTechnology.list.forEach({ tech in
            let button = RMBTMapTechnologyButton(for: tech)
            button.addTarget(self, action: #selector(switchTechnology), for: .touchUpInside)
            button.colorizeIf(selectedTech.name == tech.name, color: tech.color)
            technologiesView.addArrangedSubview(button)
        })
    }
    
    private func initMiniTechnologies() {
        miniTechnologiesView.subviews.forEach({ subview in
            miniTechnologiesView.removeArrangedSubview(subview)
        })
        let miniButton = RMBTMapTechnologyButton(for: selectedTech)
        miniButton.colorizeIf(true, color: selectedTech.color)
        miniButton.addTarget(self, action: #selector(toggleFiltersView), for: .touchUpInside)
        miniTechnologiesView.addArrangedSubview(miniButton)
    }
    
    private func initOperators() {
        selectedOperatorLabel.text = selectedOperator.longLabel
        selectedOperatorButton.setTitle(selectedOperator.longLabel, for: .normal)
        selectedOperatorButton.addTarget(self, action: #selector(showOperatorSheet), for: .touchUpInside)
        httpService.getOperators(completion: { [weak self] operators in
            DispatchQueue.main.async {
                self?.operators = operators
            }
        })
    }
    
    private func initDates() {
        httpService.getDefaultDate { [weak self] defaultDate in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.selectedDate = defaultDate
                self.selectedDateButton.addTarget(self, action: #selector(self.showDateSheet), for: .touchUpInside)
                self.view.bringSubviewToFront(self.selectedDateButton)
            }
        }
    }
    
    private func initDetails() {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(showDetailsSheet))
        for recognizer in mapView.gestureRecognizers! where recognizer is UITapGestureRecognizer {
            singleTap.require(toFail: recognizer)
        }
        mapView.addGestureRecognizer(singleTap)
    }
    
    private func rearrangeWidgets() {
        technologiesView.isHidden = !isFiltersViewOpen
        miniTechnologiesView.isHidden = isFiltersViewOpen
        selectedOperatorLabel.isHidden = isFiltersViewOpen
        infoIcon.isHidden = isFiltersViewOpen
        filtersViewHeightConstraint.constant = isFiltersViewOpen ? 168 : 64
    }
    
    private func switchVisibleLayer() {
        guard let style = mapView.style else {
            return
        }
        style.layers.forEach({layer in
            let prefixString = String(layer.identifier.split(separator: "-")[0])
            // Hide all layers that have a regional prefix, are not selected and are not regional borders
            if let prefix = RMBTMapRegionalPrefix(rawValue: prefixString), RMBTMapRegionalPrefix.allCases.contains(prefix), layer.identifier != selectedLayerId, !layer.identifier.contains("Borders") {
                layer.isVisible = false
            }
        })
        if let layer = style.layer(withIdentifier: selectedLayerId), !layer.isVisible {
            layer.isVisible = true
        }
    }
}
