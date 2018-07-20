//
//  EventDetailViewController.swift
//  KGHS
//
//  Created by Collin DeWaters on 7/19/18.
//  Copyright © 2018 Collin DeWaters. All rights reserved.
//

import UIKit

//`EventDetailViewController`: shows all details of a selected event.
class EventDetailViewController: UIViewController {
    
    //MARK: - IBOutlets.
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    //MARK: - Properties.
    ///The event to display.
    var event: Event?
    
    ///The shared instance.
    static var shared = mainStoryboard.instantiateViewController(withIdentifier: "eventDetailVC") as! EventDetailViewController
    
    //MARK: - `UIViewController` overrides.

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Preferred height (for previewing).
        self.preferredContentSize.height = 250
        
        //Setup UI with event.
        self.titleLabel.text = event?.calendarEvent?.eventSummary ?? "No Title"
        
        //Image view.
        self.iconImageView.image = self.event?.subCategory?.icon ?? ((self.event?.category == .athletics) ? UIImage(named: "athletics") : UIImage(named: "academics"))
        self.iconImageView.layer.cornerRadius = 15
        self.iconImageView.tintColor = .blueTheme

        //Date.
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        self.dateLabel.text = dateFormatter.string(from: self.event?.calendarEvent?.eventStartDate ?? Date())
        
        //Category label.
        var categoryLabelText = self.event?.category.displayTitle ?? ""
        
        if let subCategory = self.event?.subCategory {
            categoryLabelText = categoryLabelText + " • \(subCategory.displayTitle)"
        }
        self.categoryLabel.text = categoryLabelText

        //Description label.
        self.descriptionLabel.text = event?.calendarEvent?.eventDescription ?? ""
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        EventDetailViewController.shared = mainStoryboard.instantiateViewController(withIdentifier: "eventDetailVC") as! EventDetailViewController
    }
}
