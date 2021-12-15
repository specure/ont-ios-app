//
//  RMBTMapOperator.swift
//  RMBT
//
//  Created by Polina on 28.09.2021.
//  Copyright © 2021 SPECURE GmbH. All rights reserved.
//

import Foundation

struct RMBTMapOperator {
    
    static var list = [ RMBTMapOperator(name: "ALL", shortLabel: L("map.operator.all.short"), longLabel: L("map.operator.all.long")) ]
    
    let name: String
    let shortLabel: String
    let longLabel: String
    
    init(name: String, shortLabel: String, longLabel: String?) {
        self.name = name
        self.shortLabel = shortLabel
        self.longLabel = longLabel ?? shortLabel
    }
}
