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

///
class ClassifyableKeyValueTableViewCell: KeyValueTableViewCell {

    ///
    @IBOutlet private var classifyView: UIView?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let theSubView = UIView(frame: CGRect(origin: CGPoint(x: 3, y: 2.5), size: CGSize(width: 10, height: 25)))
        
        classifyView = theSubView
        self.addSubview(classifyView!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //
        self.textLabel?.font = UIFont.systemFont(ofSize: 15.0)
        self.textLabel?.textColor = RMBT_TINT_COLOR
        
    }

    ///
    var classification: Int? {
        didSet {
            switch classification ?? 0 {
            case 1: classifyView?.backgroundColor = RMBT_CHECK_INCORRECT_COLOR
            case 2: classifyView?.backgroundColor = RMBT_CHECK_MEDIOCRE_COLOR
            case 3: classifyView?.backgroundColor = RMBT_CHECK_CORRECT_COLOR
            default: classifyView?.backgroundColor = UIColor.clear
            }
        }
    }
}
