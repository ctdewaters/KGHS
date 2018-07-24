//
//  DeveloperViewController.swift
//  KGHS
//
//  Created by Collin DeWaters on 7/23/18.
//  Copyright © 2018 Collin DeWaters. All rights reserved.
//

import UIKit
import SafariServices
import MessageUI

///`DeveloperViewController`: displays information about the developer.
class DeveloperViewController: UIViewController, SFSafariViewControllerDelegate, MFMailComposeViewControllerDelegate {
    
    //MARK: - IBOutlets.
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var githubButton: UIButton!
    @IBOutlet weak var feedbackButton: UIButton!
    @IBOutlet weak var ctdewatersButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //MARK: - Properties.
    var safariVC: SFSafariViewController?
    var mailVC: MFMailComposeViewController?
    
    //MARK: - UIViewController overrides.
    override func viewDidLoad() {
        super.viewDidLoad()

        self.profilePictureImageView.layer.cornerRadius = 50
        for view in self.scrollView.subviews {
            if let button = view as? UIButton {
                button.setTitleColor(.blueTheme, for: .normal)
                button.tintColor = .blueTheme
                button.layer.cornerRadius = 10
                button.imageView?.contentMode = .scaleAspectFit
            }
        }
        
        if !MFMailComposeViewController.canSendMail() {
            self.feedbackButton.isEnabled = false
            self.feedbackButton.alpha = 0.5
        }
        else {
            self.feedbackButton.isEnabled = true
            self.feedbackButton.alpha = 1
        }
    }
    
    //MARK: - IBActions.
    @IBAction func actionButtonPressed(_ sender: UIButton) {
        if sender == self.githubButton {
            if let url = URL(string: "https://github.com/ctdewaters/KGHS") {
                self.safariVC = SFSafariViewController(url: url)
                self.safariVC?.delegate = self
                self.present(self.safariVC!, animated: true, completion: nil)
            }
        }
        else if sender == self.feedbackButton {
            self.mailVC = MFMailComposeViewController()
            self.mailVC?.setSubject("Feedback: KGHS App for iOS")
            self.mailVC?.setToRecipients(["ctdewaters@icloud.com"])
            
            self.mailVC?.mailComposeDelegate = self
            
            self.present(self.mailVC!, animated: true, completion: nil)
        }
        else if sender == self.ctdewatersButton {
            if let url = URL(string: "https://itunes.apple.com/us/developer/collin-dewaters/id932176134") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    //MARK: - SFSafariViewControllerDelegate
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
