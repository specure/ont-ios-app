//
//  RMBTMapBottomSheetViewController.swift
//  RMBT
//
//  Created by Polina on 01.10.2021.
//  Copyright © 2021 SPECURE GmbH. All rights reserved.
//

import UIKit

enum RMBTMapBottomSheetView {
    case operators
    case dates
    case details
}

class RMBTMapBottomSheetViewController: RMBTBottomSheetViewController, UITableViewDataSource {
    static let detailsCellId = "cell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var operatorsView: UIStackView!
    @IBOutlet weak var datePickerView: UIPickerView!
    @IBOutlet weak var detailsView: UITableView!
    @IBOutlet weak var detailsViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var operatorsViewHeightConstraint: NSLayoutConstraint!
    
    var selectedDate: RMBTMapDate!
    var selectedOperator: RMBTMapOperator!
    var selectedFeatureDetails: [RMBTMapDetailsRow] = []
    var datePickerViewDelegate: RMBTMapDatePickerDelegate!
    var sheetTitle: String?
    var delegate: RMBTMapViewControllerDelegate?
    var operators: [RMBTMapOperator] = RMBTMapOperator.list
    var visibleView: RMBTMapBottomSheetView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initBottomSheet()
        initOperators()
        initDates()
        initDetails()
    }
    
    func initOperators() {
        guard visibleView == .operators else {
            return
        }
        operatorsViewHeightConstraint.constant = sheetHeight - RMBTMapDetailsRow.height - 1
        for (index, op) in operators.enumerated() {
            let button: RMBTMapOperatorButton = RMBTMapOperatorButton(for: op, within: operatorsView)
            if op.name == selectedOperator.name {
                button.setTitleColor(RMBTColorManager.mapSelectionColor, for: .normal)
            }
            // Don't show the separator for the last button
            if index == operators.count - 1 {
                button.layer.sublayers?.last?.removeFromSuperlayer()
            }
            button.addTarget(self, action: #selector(switchOperator), for: .touchUpInside)
            operatorsView.addArrangedSubview(button)
        }
    }
    
    func initDates() {
        guard visibleView == .dates else {
            return
        }
        datePickerViewDelegate = RMBTMapDatePickerDelegate(for: RMBTMapDate.list, withSelected: selectedDate, { [weak self] date in
            if let presenter = self?.delegate {
                presenter.setDate(date)
            }
        })
        datePickerView.dataSource = datePickerViewDelegate
        datePickerView.delegate = datePickerViewDelegate
        if let selectedYearIndex = datePickerViewDelegate.years.firstIndex(where: { year in
            return year == selectedDate.year
        }) {
            datePickerView.selectRow(selectedYearIndex, inComponent: 0, animated: false)
        }
        if let selectedMonthIndex = datePickerViewDelegate.months[selectedDate.year]!.firstIndex(where: { monthName in
            return monthName == selectedDate.monthName
        }) {
            datePickerView.selectRow(selectedMonthIndex, inComponent: 1, animated: false)
        }
    }
    
    func initDetails() {
        guard visibleView == .details else {
            return
        }
        detailsView.register(RMBTMapDetailsViewCell.self, forCellReuseIdentifier: RMBTMapBottomSheetViewController.detailsCellId)
        detailsView.dataSource = self
        detailsView.rowHeight = RMBTMapDetailsRow.height
        // Sheet height minus header row's height minus last item's border
        detailsViewHeightContraint.constant = sheetHeight - RMBTMapDetailsRow.height - 1
    }
    
    func initBottomSheet() {
        if let title = sheetTitle?.uppercased() {
            titleLabel.text = title
        }
        operatorsView.isHidden = visibleView != .operators
        datePickerView.isHidden = visibleView != .dates
        detailsView.isHidden = visibleView != .details
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedFeatureDetails.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = detailsView.dequeueReusableCell(withIdentifier: RMBTMapBottomSheetViewController.detailsCellId, for: indexPath) as! RMBTMapDetailsViewCell
        cell.labelView.text = selectedFeatureDetails[indexPath.row].label
        cell.valueView.text = selectedFeatureDetails[indexPath.row].value
        return cell
    }
    
    @objc func switchOperator(sender: RMBTMapOperatorButton?) {
        guard let button = sender else {
            return
        }
        if let presenter = delegate {
            presenter.setOperator(button.op)
        }
        closeBottomSheet()
    }
}
