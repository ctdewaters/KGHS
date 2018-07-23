//
//  EventDetailViewController.swift
//  KGHS
//
//  Created by Collin DeWaters on 7/19/18.
//  Copyright © 2018 Collin DeWaters. All rights reserved.
//

import UIKit
import EventKit

//`EventDetailViewController`: shows all details of a selected event.
class EventDetailViewController: UIViewController {
    
    //MARK: - IBOutlets.
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var verticalSeparator: UIView!
    @IBOutlet weak var horizontalSeparator: UIView!
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    @IBOutlet weak var addToCalendarButton: UIButton!
    
    //MARK: - Properties.
    ///The event to display.
    var event: Event?
    
    ///The shared instance.
    static var shared = mainStoryboard.instantiateViewController(withIdentifier: "eventDetailVC") as! EventDetailViewController
    
    ///The event store.
    let eventStore = EKEventStore()
    
    //MARK: - `UIViewController` overrides.

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        self.descriptionLabel.text = self.event?.calendarEvent?.eventDescription ?? ""
        
        self.favoriteButton.image = (self.event?.isFavorited ?? false) ? UIImage(named: "favoriteFilled") : UIImage(named: "favoriteEmpty")
        
        self.addToCalendarButton.layer.cornerRadius = 10
        self.addToCalendarButton.setTitleColor(.blueTheme, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        //Preferred height (for previewing).
        if self.isPortrait {
            self.preferredContentSize.height = 188 + (self.descriptionLabel.text?.height(withConstrainedWidth: self.view.frame.width - 32, font: UIFont.preferredFont(forTextStyle: .body)) ?? 0)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        EventDetailViewController.shared = mainStoryboard.instantiateViewController(withIdentifier: "eventDetailVC") as! EventDetailViewController
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //Hiding separator.
        if self.isPortrait {
            self.horizontalSeparator.isHidden = true
            self.verticalSeparator.isHidden = false
        }
        else {
            self.horizontalSeparator.isHidden = false
            self.verticalSeparator.isHidden = true
        }
    }
    
    override var previewActionItems: [UIPreviewActionItem] {
        let favoriteAction = UIPreviewAction(title: (self.event?.isFavorited ?? false) ? "Unfavorite" : "Favorite", style: .default) { (action, viewController) in
            self.favorite(self)
        }
        return [favoriteAction]
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
        guard let event = self.event else {
            return
        }
        
        self.favoriteButton.image = event.isFavorited ?  UIImage(named: "favoriteEmpty") : UIImage(named: "favoriteFilled")
        
        if event.isFavorited {
            Haptics.shared.sendImpactHaptic(withStyle: .light)
        }
        else {
            Haptics.shared.sendImpactHaptic(withStyle: .heavy)
        }

        DispatchQueue.global(qos: .background).async {
            self.event?.favorite()
            //Update global events view controller favorited events array.
            EventsViewController.global?.favoritedEvents = EventsViewController.global?.events.filter {
                $0.isFavorited
            } ?? []
            
            EventsViewController.global?.reloadCollectionView()
        }
        
        //Check if this is the first event the user has favorited, and if notifications are authorized.
        if !Settings.favoritedFirstEvent && AppDelegate.notificationSettings?.authorizationStatus == .authorized {
            Settings.favoritedFirstEvent = true
            
            //Send alert explaining how favorited events work.
            let alertController = UIAlertController(title: "Favoriting Events", message: "When you favorite an event, you will be notified at certain times before it occurs. You can change this in the Settings menu (More -> Settings).", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                alertController.dismiss(animated: true, completion: nil)
            }))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func actionButtonPressed(_ sender: UIButton) {
        if sender == self.addToCalendarButton {
            //Add event to calendar.
            self.addEventToCalendar()
        }
    }
    
    //MARK: - UIAlertController
    ///Constructs an alert controller with no actions.
    func alert(title: String, message: String) -> UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { action->Void in
            self.dismiss(animated: true, completion: nil)
        })
        alert.addAction(cancelAction)
        return alert
    }

    
    //MARK: - EventKit
    //Adds the event to the user's default calendar.
    func addEventToCalendar(){
        switch EKEventStore.authorizationStatus(for: EKEntityType.event){
        case .authorized:
            print("Authorized")
            self.insertEvent(intoEventStore: self.eventStore)
        case .denied:
            print("Denied")
            self.present(self.alert(title: "Calendar Unavailable", message: "Couldn't add the event to your calendar."), animated: true, completion: nil)
        case .notDetermined:
            eventStore.requestAccess(to: .event) { (granted, error) in
                if granted {
                    self.insertEvent(intoEventStore: self.eventStore)
                }
            }
        default:
            break
        }
    }
    
    func insertEvent(intoEventStore store: EKEventStore){
        if let event = self.event?.calendarEvent?.convertToEKEvent(on: self.event?.calendarEvent?.eventStartDate ?? Date(), store: store) {
            event.calendar = store.defaultCalendarForNewEvents
            event.startDate = self.event?.calendarEvent?.eventStartDate
            event.endDate = self.event?.calendarEvent?.eventEndDate
            
            do {
                try store.save(event, span: EKSpan.thisEvent)
                self.present(self.alert(title: "Event Added To Calendar", message: ""), animated: true, completion: nil)
            }
            catch {
                print(error.localizedDescription)
                self.present(self.alert(title: "Error Adding Event", message: ""), animated: true, completion: nil)
            }
        }
    }
}
