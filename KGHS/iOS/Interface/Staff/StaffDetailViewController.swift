//
//  StaffDetailViewController.swift
//  KGHS
//
//  Created by Collin DeWaters on 7/20/18.
//  Copyright © 2018 Collin DeWaters. All rights reserved.
//

import UIKit
import SafariServices
import MessageUI

//`StaffDetailViewController`: shows all details of a selected staff member.
class StaffDetailViewController: UIViewController, SFSafariViewControllerDelegate, MFMailComposeViewControllerDelegate, UIViewControllerPreviewingDelegate {
    
    //MARK: - IBOutlets.
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var verticalSeparator: UIView!
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    @IBOutlet weak var viewWebpageButton: UIButton!
    @IBOutlet weak var sendEmailButton: UIButton!
    
    //MARK: - Properties.
    ///The event to display.
    var staffMember: Staff?
    
    ///The shared instance.
    static var shared = mainStoryboard.instantiateViewController(withIdentifier: "staffDetailVC") as! StaffDetailViewController
    
    //MARK: - `UIViewController` overrides.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up UI with the staff member property.
        self.nameLabel.text = self.staffMember?.name ?? "No Name"
        
        //Dpeartment label.
        var departmentLabelText = self.staffMember?.departmentValue?.displayTitle ?? "No Subject"
        if let organization = self.staffMember?.organization {
            if organization != "" {
                departmentLabelText += " • \(organization)"
            }
        }
        self.departmentLabel.text = departmentLabelText

        //Icon image view.
        self.iconImageView.image = UIImage(named: "kghsLogo")
        self.iconImageView.layer.cornerRadius = 15
        self.iconImageView.backgroundColor = .lightGray
        
        //Favorite button.
        self.favoriteButton.image = (self.staffMember?.isFavorited ?? false) ? UIImage(named: "favoriteFilled") : UIImage(named: "favoriteEmpty")
        
        //Button title text.
        if self.staffMember?.websiteURL == nil {
            self.viewWebpageButton.isHidden = true
        }
        if self.staffMember?.email == nil || !MFMailComposeViewController.canSendMail() {
            self.sendEmailButton.isHidden = true
        }
        
        //Action button setup.
        self.viewWebpageButton.setTitleColor(.yellowTheme, for: .normal)
        self.sendEmailButton.setTitleColor(.yellowTheme, for: .normal)
        self.viewWebpageButton.layer.cornerRadius = 10
        self.sendEmailButton.layer.cornerRadius = 10
        
        //Register for view controller previewing.
        self.registerForPreviewing(with: self, sourceView: self.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        //Preferred height (for previewing).
        if self.isPortrait {
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        StaffDetailViewController.shared = mainStoryboard.instantiateViewController(withIdentifier: "staffDetailVC") as! StaffDetailViewController
    }
    
    //MARK: - Portrait detection.
    ///Returns true if the device is currently portrait.
    var isPortrait: Bool {
        if self.view.frame.width > self.view.frame.height {
            return false
        }
        return true
    }
    
    //MARK: - IBActions.
    @IBAction func favorite(_ sender: Any) {
        guard let staffMember = self.staffMember else {
            return
        }
        
        self.favoriteButton.image = staffMember.isFavorited ?  UIImage(named: "favoriteEmpty") : UIImage(named: "favoriteFilled")
        
        if staffMember.isFavorited {
            Haptics.shared.sendImpactHaptic(withStyle: .light)
        }
        else {
            Haptics.shared.sendImpactHaptic(withStyle: .heavy)
        }

        
        DispatchQueue.global(qos: .background).async {
            staffMember.favorite()
            //Update global staff view controller favorited staff array.
            var filteredFavoriteStaff = [Staff]()
            for key in StaffViewController.global!.fetchedStaffKeys {
                let staffArray = StaffViewController.global!.fetchedStaff[key]!
                filteredFavoriteStaff.append(contentsOf: staffArray.filter {
                    $0.isFavorited
                })
            }
            StaffViewController.global?.favoritedStaff = filteredFavoriteStaff
            StaffViewController.global?.reloadCollectionView()
        }
    }
    
    @IBAction func actionButtonPressed(_ sender: UIButton) {
        if sender == self.sendEmailButton {
            //Send email.
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            composeVC.setToRecipients([self.staffMember?.email ?? ""])
            self.present(composeVC, animated: true, completion: nil)
            
            return
        }
        //View webpage in a safari view controller.
        if let url = URL(string: self.staffMember?.websiteURL ?? "") {
            let safariVC = SFSafariViewController(url: url)
            safariVC.delegate = self
            
            self.present(safariVC, animated: true, completion: nil)
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
    
    //MARK: - UIViewControllerPreviewingDelegate
    //Peek
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if self.viewWebpageButton.frame.contains(location) {
            //View webpage in a safari view controller.
            if let url = URL(string: self.staffMember?.websiteURL ?? "") {
                previewingContext.sourceRect = self.viewWebpageButton.frame
                let safariVC = SFSafariViewController(url: url)
                safariVC.delegate = self
                
                return safariVC
            }
        }
        else if self.sendEmailButton.frame.contains(location) {
            previewingContext.sourceRect = self.sendEmailButton.frame

            //Send email.
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            composeVC.setToRecipients([self.staffMember?.email ?? ""])

            return composeVC
        }
        return nil
    }
    
    //Pop
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.present(viewControllerToCommit, animated: true, completion: nil)
    }
}
