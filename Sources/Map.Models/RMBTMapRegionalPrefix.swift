//
//  RMBTMapRegionalPrefix.swift
//  RMBT
//
//  Created by Polina on 27.09.2021.
//  Copyright © 2021 SPECURE GmbH. All rights reserved.
//

import Foundation

enum RMBTMapRegionalPrefix: String, CaseIterable {
    case county = "C"
    case municipality = "M"
    case squares10meters = "H10"
    case squares1meters = "H1"
    case squares01meters = "H01"
    case squares001meters = "H001"
}
