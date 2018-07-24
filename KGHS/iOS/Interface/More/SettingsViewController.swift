//
//  SettingsViewController.swift
//  KGHS
//
//  Created by Collin DeWaters on 7/23/18.
//  Copyright © 2018 Collin DeWaters. All rights reserved.
//

import UIKit

///`SettingsViewController`: displays notification settings.
class SettingsViewController: UIViewController {
    //MARK: - IBOutlets.
    @IBOutlet weak var weekAlertSwitch: UISwitch!
    @IBOutlet weak var dayAlertSwitch: UISwitch!
    @IBOutlet weak var hourAlertSwitch: UISwitch!
    @IBOutlet weak var openSettingsButton: UIButton!
    
    //MARK: - UIViewController overrides.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup view apperances.
        self.weekAlertSwitch.onTintColor = .blueTheme
        self.dayAlertSwitch.onTintColor = .blueTheme
        self.hourAlertSwitch.onTintColor = .blueTheme
        self.openSettingsButton.setTitleColor(.blueTheme, for: .normal)
        self.openSettingsButton.layer.cornerRadius = 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Check current settings.
        if AppDelegate.notificationSettings?.authorizationStatus != .authorized {
            //Notifications not authorized, disable switches.
            self.weekAlertSwitch.isEnabled = false
            self.dayAlertSwitch.isEnabled = false
            self.hourAlertSwitch.isEnabled = false
        }
        else {
            //Notifications authorized, enable switches.
            self.weekAlertSwitch.isEnabled = true
            self.dayAlertSwitch.isEnabled = true
            self.hourAlertSwitch.isEnabled = true
            
            //Set switch values to current settings.
            self.weekAlertSwitch.isOn = Settings.weekNotificationsEnabled
            self.dayAlertSwitch.isOn = Settings.dayNotificationsEnabled
            self.hourAlertSwitch.isOn = Settings.hourNotificationsEnabled
        }
    }
    
    //MARK: - IBActions.
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        if sender == self.weekAlertSwitch {
            Settings.weekNotificationsEnabled = self.weekAlertSwitch.isOn
        }
        else if sender == self.dayAlertSwitch {
            Settings.dayNotificationsEnabled = self.dayAlertSwitch.isOn
        }
        else if sender == self.hourAlertSwitch {
            Settings.hourNotificationsEnabled = self.hourAlertSwitch.isOn
        }
    }
    
    @IBAction func openSettings(_ sender: UIButton) {
        if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
    }
}
