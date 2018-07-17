//
//  PowerSchoolViewController.swift
//  KGHS
//
//  Created by Collin DeWaters on 7/17/18.
//  Copyright © 2018 Collin DeWaters. All rights reserved.
//

import UIKit
import WebKit

///`PowerSchoolViewController`: displays a webkit view showing the powerschool site.
class PowerSchoolViewController: UIViewController, WKNavigationDelegate {

    //MARK: - IBOutlets.
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - UIViewController overrides.
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.webView.navigationDelegate = self
        
        let request = URLRequest(url: URL(string: "https://ps.kgcs.k12.va.us/public/")!)
        self.webView.load(request)
    }
    
    //MARK: - `WKNavigationDelegate`.
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
    }
}
