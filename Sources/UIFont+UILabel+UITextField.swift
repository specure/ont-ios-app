//
//  UIFont+UILabel+UITextField.swift
//  RMBT
//
//  Created by Polina on 11.10.2021.
//  Copyright © 2021 SPECURE GmbH. All rights reserved.
//

import UIKit

extension UIFont {
    class var appRegularFontName: String? {
        let config = RMBTConfiguration
        guard config.RMBT_USE_CUSTOM_FONT, let customFontName = config.RMBT_CUSTOM_FONT_NAME else {
            return nil
        }
        return customFontName
    }
    
    class func appRegularFontWith( size:CGFloat ) -> UIFont{
        guard let appRegularFontName = appRegularFontName else {
            return UIFont.systemFont(ofSize: size)
        }
        return UIFont(name: appRegularFontName, size: size)!
    }
    
    class var appRegularFontAsBase64: String? {
        guard let appRegularFontName = appRegularFontName, let filePath = Bundle.main.url(forResource: appRegularFontName, withExtension: "ttf"), let data = try? Data.init(contentsOf: filePath) else { return nil }
        return data.base64EncodedString()
    }
}

extension UILabel {
    override open func layoutSubviews() {
        super.layoutSubviews()
        if RMBTConfiguration.RMBT_USE_CUSTOM_FONT {
            DispatchQueue.main.async {
                self.font = UIFont.appRegularFontWith(size: self.font?.pointSize ?? 12)
            }
        }
    }
}

extension UITextField {
    override open func layoutSubviews() {
        super.layoutSubviews()
        if RMBTConfiguration.RMBT_USE_CUSTOM_FONT {
            DispatchQueue.main.async {
                self.font = UIFont.appRegularFontWith(size: self.font?.pointSize ?? 12)
            }
        }
    }
}
