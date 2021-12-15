//
//  RMBTMapDate.swift
//  RMBT
//
//  Created by Polina on 30.09.2021.
//  Copyright © 2021 SPECURE GmbH. All rights reserved.
//

import Foundation

struct RMBTMapDate {
    static var list: [RMBTMapDate] {
        var retVal: [RMBTMapDate] = []
        for index in 0..<23 {
            if let date = Calendar.current.date(byAdding: .month, value: -index, to: Date()) {
                retVal.append( RMBTMapDate(from: date) )
            }
        }
        return retVal
    }
    
    var date: Date
    var year: String { "\(Calendar.current.component(.year, from: date))" }
    var month: String { String(format: "%02d", Calendar.current.component(.month, from: date)) }
    var code: String { "\(year)\(month)" }
    var monthName: String {
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("MMMM")
        return df.string(from: date)
    }
    var monthNameAndYear: String {
        return "\(monthName.capitalizingFirstLetter()) \(year)"
    }
    
    init(from date: Date) {
        self.date = date
    }
    
    init(_ y: String, _ m: String) {
        let df = DateFormatter()
        df.dateFormat = "yyyy LLLL"
        self.date = df.date(from: "\(y) \(m)") ?? Date()
    }
}
