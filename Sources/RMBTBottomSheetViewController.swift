//
//  RMBTBottomSheetViewController.swift
//  RMBT
//
//  Created by Polina on 07.10.2021.
//  Copyright © 2021 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTBottomSheetViewController: UIViewController {

    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var sheetView: UIView!
    @IBOutlet weak var sheetHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeButton: UIButton!

    var sheetHeight: CGFloat = 0
    var initialCenter: CGPoint?
    var yThreshold: CGFloat = 0.3
    var velocityThreshold: CGFloat = 1500
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overlayView.backgroundColor = .black.withAlphaComponent(0.0)
        sheetHeightConstraint.constant = 0
        sheetView.layer.cornerRadius = 16
        sheetView.layer.masksToBounds = true
        sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner ]
        closeButton.addTarget(self, action: #selector(closeBottomSheet), for: .touchUpInside)
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        sheetView.addGestureRecognizer(panRecognizer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.2, animations: {
            self.overlayView.backgroundColor = .black.withAlphaComponent(0.5)
            self.sheetHeightConstraint.constant = self.sheetHeight + self.overlayView.safeAreaInsets.bottom
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func closeBottomSheet() {
        UIView.animate(withDuration: 0.2, animations: {
            self.overlayView.backgroundColor = .black.withAlphaComponent(0.0)
            self.sheetHeightConstraint.constant = 0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.dismiss(animated: false, completion: nil)
        })
    }
    
    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        guard let sheet = sender.view else { return }

        switch(sender.state) {
        case .began:
            initialCenter = sheet.center
        case .changed:
            let yTranslation = sender.translation(in: sheet.superview).y
            if yTranslation > 0 {
                sheet.center.y = yTranslation + (initialCenter?.y ?? 0)
            }
        case .ended:
            let reachedYThreshold = sender.translation(in: sheet.superview).y > sheet.frameHeight * yThreshold
            let reachedVelocityThreshold = sender.velocity(in: sender.view).y > velocityThreshold
            if reachedYThreshold || reachedVelocityThreshold {
                closeBottomSheet()
            } else {
                fallthrough
            }
        default:
            if let initialCenter = initialCenter {
                sheet.center = initialCenter
            }
        }
    }
}
