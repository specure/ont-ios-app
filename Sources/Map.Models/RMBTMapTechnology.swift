//
//  RMBTMapTechnology.swift
//  RMBT
//
//  Created by Polina on 23.09.2021.
//  Copyright © 2021 SPECURE GmbH. All rights reserved.
//

import Foundation

struct RMBTMapTechnology {
    
    static var list: [RMBTMapTechnology] {
        return [
            RMBTMapTechnology("ALL", color: UIColor(rgb: 0x4069F2), textColor: UIColor.white, label: L("map.technology.all")),
            RMBTMapTechnology("2G", color: UIColor(red: 0.97, green: 0.71, blue: 0, alpha: 1), textColor: UIColor.black, label: nil),
            RMBTMapTechnology("3G", color: UIColor(red: 0.43, green: 0.83, blue: 0, alpha: 1), textColor: UIColor.black, label: nil),
            RMBTMapTechnology("4G", color: UIColor(red: 0.27, green: 0.84, blue: 0.71, alpha: 1), textColor: UIColor.black, label: nil),
            RMBTMapTechnology("5G", color: UIColor(red: 0.38, green: 0.21, blue: 1, alpha: 1), textColor: UIColor.white, label: nil),
        ]
    }
    
    let color: UIColor
    let name: String
    let label: String
    let textColor: UIColor
    
    init(_ name: String, color: UIColor, textColor: UIColor, label: String?) {
        self.name = name
        self.color = color
        self.textColor = textColor
        self.label = label ?? name
    }
}
