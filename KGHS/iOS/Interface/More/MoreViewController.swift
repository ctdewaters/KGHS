//
//  MoreViewController.swift
//  KGHS
//
//  Created by Collin DeWaters on 7/19/18.
//  Copyright © 2018 Collin DeWaters. All rights reserved.
//

import UIKit
import SafariServices

class MoreViewController: UIViewController, SFSafariViewControllerDelegate {
    
    //MARK: - IBOutlets.
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var kghsNewsButton: UIButton!
    @IBOutlet weak var alumniButton: UIButton!
    @IBOutlet weak var developerButton: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var lunchMenusButton: UIButton!
    
    
    //MARK: - Properties.
    ///The safari view controller.
    var safariViewController: SFSafariViewController?
    

    //MARK: - `UIViewController` overrides.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = .blueTheme
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.versionLabel.text = "KGHS v\(version)\n\nCreated by Collin DeWaters."
        }
        else {
            self.versionLabel.isHidden = true
        }
        
        //Button colors.
        self.alumniButton.setTitleColor(.blueTheme, for: .normal)
        self.kghsNewsButton.setTitleColor(.blueTheme, for: .normal)
        self.developerButton.setTitleColor(.blueTheme, for: .normal)
        self.settingsButton.setTitleColor(.blueTheme, for: .normal)
        self.lunchMenusButton.setTitleColor(.blueTheme, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Navigation bar setup.
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = true
        
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Reset navigation bar.
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.hideHairline()
                
        //Apperance setup.
        self.tabBarController?.tabBar.barStyle = .default
        self.tabBarController?.tabBar.tintColor = .blueTheme
        UIApplication.shared.statusBarStyle = .default
    }
    
    //MARK: - IBAction.
    @IBAction func buttonSelected(_ sender: UIButton) {
        if sender == self.alumniButton {
            if let alumniURL = URL(string: "https://www.alumniclass.com/king-george-high-school-foxes-va/") {
                self.safariViewController = SFSafariViewController(url: alumniURL)
                self.safariViewController?.delegate = self
                self.present(self.safariViewController!, animated: true, completion: nil)
            }
        }
        else if sender == self.kghsNewsButton {
            if let newsURL = URL(string: "http://www.kghs-kgcs.org/kghs-news") {
                self.safariViewController = SFSafariViewController(url: newsURL)
                self.safariViewController?.delegate = self
                self.present(self.safariViewController!, animated: true, completion: nil)
            }
        }
        else if sender == self.lunchMenusButton {
            if let menusURL = URL(string: "https://www.schoolnutritionandfitness.com/index.php?sid=1468870899202&page=menus") {
                self.safariViewController = SFSafariViewController(url: menusURL)
                self.safariViewController?.delegate = self
                self.present(self.safariViewController!, animated: true, completion: nil)
            }
        }
        else if sender == self.settingsButton {
            //Show settings.
            self.performSegue(withIdentifier: "showSettings", sender: self)
            
        }
        else if sender == self.developerButton {
            //Show developer info.
            self.performSegue(withIdentifier: "showDeveloper", sender: self)
        }
    }
    
    //MARK: - SFSafariViewControllerDelegate
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
