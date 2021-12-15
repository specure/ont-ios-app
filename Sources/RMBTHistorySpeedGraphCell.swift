//
//  RMBTHistorySpeedGraphCell.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 05.07.2021.
//  Copyright © 2021 SPECURE GmbH. All rights reserved.
//

import UIKit

final class RMBTHistorySpeedGraphCell: UITableViewCell {

    @IBOutlet var activityView: UIActivityIndicatorView!
    @IBOutlet var speedGraphView: RMBTSpeedGraphView!
    
    func drawSpeedGraph(_ throughputs: [RMBTThroughput]?) {
        if let throughputs = throughputs {
            self.activityView.stopAnimating()
            self.speedGraphView.clear()
            for t in throughputs {
                self.speedGraphView.addValue(RMBTSpeedLogValue(t.kilobitsPerSecond()), atTimeInterval: TimeInterval(t.endNanos / NSEC_PER_SEC))
            }
            self.speedGraphView.isHidden = false
        } else {
            self.speedGraphView.isHidden = true
            self.activityView.startAnimating()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isUserInteractionEnabled = false
    }
}
