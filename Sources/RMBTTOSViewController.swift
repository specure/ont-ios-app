/*****************************************************************************************************
 * Copyright 2013 appscape gmbh
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
import RMBTClient
import WebKit

///
class RMBTTOSViewController: UIViewController, WKNavigationDelegate {
    
    ///
    @IBOutlet private var activityIndicator: UIActivityIndicatorView?

    ///
    @IBOutlet private var webView: WKWebView!

    @IBOutlet weak var toolbarView: UIView!
    
    ///
    @IBOutlet private var acceptIntroLabel: UILabel!

    //
    @IBOutlet private var toolBar: UIToolbar!
    
    //
    @IBOutlet internal var titleLabel: UIButton?
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        self.view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            webView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            webView.topAnchor.constraint(equalTo: self.view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: self.toolbarView.topAnchor)
        ])
        // NT-367
        //
        if RMBT_SHOW_PRIVACY_POLICY == true {
            self.titleLabel?.setTitle(String.formatStringTermAndConditions(), for: .normal)
        } else {
            self.titleLabel?.setTitle(String.formatStringPrivacyAndPolicy(), for: .normal)
        }
        
        self.titleLabel?.titleLabel?.adjustsFontSizeToFitWidth = true
        self.titleLabel?.titleLabel?.minimumScaleFactor = 0.8
        
        self.navigationItem.titleView = titleLabel
        //self.navigationItem.title?.formatStringPrivacyAndPolicy()
        //
        
        if RMBT_SHOW_PRIVACY_POLICY == true {
            self.acceptIntroLabel.text = String.formatStringAgreementTermsText()
        } else {
            self.acceptIntroLabel.text = String.formatStringAgreementText()
        }
        self.toolBar.formatStringAgreementOptions()

        if let url = URL(string: RMBTLocalizeURLString(RMBTConfiguration.RMBT_TERMS_TOS_URL)) {
            webView.load(URLRequest(url: url))
        }
        
        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard UIApplication.shared.applicationState == .inactive else {
            return
        }
        
        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
    }
    
    func applyColorScheme() {
        self.titleLabel?.setTitleColor(RMBTColorManager.navigationBarTitleColor, for: .normal)
        self.view.tintColor = RMBTColorManager.tintColor
        self.toolBar.tintColor = RMBTColorManager.tintColor
        self.toolBar.backgroundColor = RMBTColorManager.navigationBarBackground
        self.toolBar.barTintColor = RMBTColorManager.navigationBarBackground
        for item in self.toolBar.items ?? [] {
            item.tintColor = RMBTColorManager.navigationBarTitleColor
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        var action: WKNavigationActionPolicy?
        defer {
            decisionHandler(action ?? .allow)
        }

        guard let url = navigationAction.request.url else { return }
        
        let scheme: String = url.scheme! // !
        if scheme == "mailto" {
            // TODO: Open compose dialog
            action = .cancel
        }
    }

    ///
    @IBAction func agree(_ sender: AnyObject) {
        RMBTTOS.sharedTOS.acceptCurrentVersion()

        if TEST_USE_PERSONAL_DATA_FUZZING {
            performSegue(withIdentifier: "show_publish_personal_data", sender: self)
        } else if RMBT_SHOW_PRIVACY_POLICY {
            performSegue(withIdentifier: "show_privacy_policy", sender: self)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
        
    }

    ///
    @IBAction func decline(_ sender: AnyObject) {
        RMBTTOS.sharedTOS.declineCurrentVersion()

        // quit app
        exit(EXIT_SUCCESS)
    }
}
