//
//  RMBTMapDatePickerDelegate.swift
//  RMBT
//
//  Created by Polina on 30.09.2021.
//  Copyright © 2021 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTMapDatePickerDelegate: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    var years: [String] = []
    var months: [String : [String] ] = [:]
    var selectedYear: String
    var selectedMonth: String
    var onChange: (RMBTMapDate) -> Void
    
    init(for dateList: [RMBTMapDate], withSelected date: RMBTMapDate, _ onChange: @escaping (RMBTMapDate) -> Void) {
        var years: [String] = []
        var months: [String : [String] ] = [:]
        dateList.forEach({ date in
            if !years.contains(date.year) {
                years.append(date.year)
                months[date.year] = []
            }
            months[date.year]!.append(date.monthName)
        })
        self.years = years
        self.months = months
        self.selectedYear = date.year
        self.selectedMonth = date.monthName
        self.onChange = onChange
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 96
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? years.count : months[selectedYear]!.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = view as? UILabel ?? UILabel()
        label.font = UIFont (name: "Helvetica Neue", size: 14)
        label.text = component == 0 ? years[row] : months[selectedYear]![row]
        label.textAlignment = component == 0 ? .center : .left
        var isSelected = false
        if component == 0 {
            isSelected = row == years.firstIndex(where: { y in y == selectedYear })
        } else {
            isSelected = row == months[selectedYear]!.firstIndex(where: { m in m == selectedMonth })
        }
        label.textColor = isSelected ? RMBTColorManager.mapSelectionColor : .black
        pickerView.subviews[1].backgroundColor = .clear
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            selectedYear = years[row]
            let selectedMonthIndex = row == 0 && months[selectedYear]!.count > 1 ? 1 : 0 // We preselect previous month for the current year
            selectedMonth = months[selectedYear]![selectedMonthIndex]
            DispatchQueue.main.async {
                pickerView.selectRow(selectedMonthIndex, inComponent: 1, animated: false)
            }
        } else {
            selectedMonth = months[selectedYear]![row]
        }
        onChange( RMBTMapDate(selectedYear, selectedMonth) )
        pickerView.reloadAllComponents()
    }
}
