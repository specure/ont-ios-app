//
//  RMBTStaticPageViewController.swift
//  RMBT
//
//  Created by Polina Gurina on 10.06.2021.
//  Copyright © 2021 SPECURE GmbH. All rights reserved.
//

import UIKit
import MarkdownView

class RMBTStaticPageViewController: UIViewController {
    @IBOutlet weak var contentView:MarkdownView!
    @IBOutlet weak var spinnerView:UIActivityIndicatorView!

    let client = RMBTCmsApiClient()
    let css = UIFont.appRegularFontName != nil && UIFont.appRegularFontAsBase64 != nil
        ? [
            "@font-face { font-family: '\(UIFont.appRegularFontName!)'; src: url(data:font/ttf;base64,\(UIFont.appRegularFontAsBase64!)) format('truetype'); }",
            "* { font-family: '\(UIFont.appRegularFontName!)', sans !important; }",
            ":not(a) { color: black; }"
        ].joined(separator: "\n")
        : ":not(a) { color: black; }"
    
    var route = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contentView.backgroundColor = RMBTColorManager.tableViewBackground
        spinnerView.hidesWhenStopped = true
        spinnerView.startAnimating()
        contentView.setOnTouchLink(self)
        client.getPage(route: route, completion: { [weak self] page in
            DispatchQueue.main.async {
                self?.contentView.load(markdown: page.content, enableImage: false, css: self?.css, plugins: nil, stylesheets: nil, styled: true)
                self?.navigationItem.title = page.name
                self?.spinnerView.stopAnimating()
            }
        })
    }
}
