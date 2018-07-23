//
//  FirstViewController.swift
//  KGHS
//
//  Created by Collin DeWaters on 2/21/18.
//  Copyright © 2018 Collin DeWaters. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

///`EventsViewController`: View Controller which displays events retrieved from the school's iCal feed, and the user's favorited events.
class EventsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UIViewControllerPreviewingDelegate {
    
    //MARK: - IBOutlets.
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    @IBOutlet weak var showFavoritesSegmentedControl: UISegmentedControl!

    //No events alert view.
    @IBOutlet weak var noEventsAlertView: UIView!
    @IBOutlet weak var noEventsTitleLabel: UILabel!
    @IBOutlet weak var noEventsCaptionLabel: UILabel!
    
    //MARK: - Properties.
    ///The retrieved events to display.
    var events = [Event]()
    
    ///The favorited events.
    var favoritedEvents = [Event]()
    
    ///The filtered search events to display.
    var filteredSearchEvents = [Event]()
    
    ///If true, the user is currently searching events.
    var isSearching: Bool = false
    
    ///The search controller.
    var searchController: UISearchController?
    
    ///The selected event, set after cell selection.
    var selectedEvent: Event?
    
    ///The view controller previewing object.
    var currentViewControllerPreviewing: UIViewControllerPreviewing?
    
    ///True if events are being retrieved.
    var isLoading = false
    
    var showAll: Bool {
        if self.showFavoritesSegmentedControl.selectedSegmentIndex == 0 {
            return true
        }
        return false
    }

    ///The global instance.
    public static var global: EventsViewController?

    //MARK: - `UIViewController` overrides.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        EventsViewController.global = self
        
        //Setup activity indicator.
        self.activityIndicator.color = .blueTheme
        self.activityIndicator.type = .orbit
        
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        self.navigationController?.navigationBar.tintColor = .blueTheme
        
        //Setup the search controller.
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController?.dimsBackgroundDuringPresentation = false
        self.searchController?.searchBar.tintColor = .blueTheme
        self.searchController?.searchBar.delegate = self
        self.searchController?.hidesNavigationBarDuringPresentation = false
        self.navigationItem.searchController = self.searchController
        
        self.definesPresentationContext = true
        
        //Register for view controller previewing.
        self.currentViewControllerPreviewing = self.registerForPreviewing(with: self, sourceView: self.collectionView)
        
        //Reload.
        self.reload()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Navigation bar setup.
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = true
        
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        self.reloadCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Reset navigation bar.
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.hideHairline()
        
        self.navigationItem.hidesSearchBarWhenScrolling = true

        //Apperance setup.
        self.tabBarController?.tabBar.barStyle = .default
        self.tabBarController?.tabBar.tintColor = .blueTheme
        UIApplication.shared.statusBarStyle = .default
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showEvent" {
            if let destination = segue.destination as? EventDetailViewController {
                destination.event = self.selectedEvent
            }
        }
    }
    
    //MARK: - Reloading.
    ///Reloads the collection view, retrieving events from the school's ICS feed.
    func reload() {
        self.isLoading = true
        
        //Animate activity indicator.
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        self.noEventsAlertView.isHidden = true

        //Retrive the events.
        Event.retrieve { (retrievedEvents) in
            self.isLoading = false
            //Unwrap the retreived events array.
            if let retrievedEvents = retrievedEvents {
                self.events = retrievedEvents
                self.reloadCollectionView()
                
                DispatchQueue.global(qos: .background).async {
                    self.favoritedEvents = self.events.filter {
                        $0.isFavorited
                    }
                    
                    print(self.favoritedEvents)
                }
                
                //Deactivate activity indicator
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    ///Reloads the collection view with preretrieved data.
    func reloadCollectionView() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            
            if !self.showAll && self.favoritedEvents.count == 0 {
                //Show no favorited events alert.
                self.present(noEventsAlertViewWithTitle: "No Favorited Events", andCaption: "Tap the star icon after selecting an event to favorite it.")
            }
            else if !self.isLoading && self.showAll && self.events.count == 0  {
                self.present(noEventsAlertViewWithTitle: "No Events Found", andCaption: "Could not retrieve calendar events. Please try again.")
            }
            else {
                self.dismissNoEventsAlertView()
            }
        }
    }
    
    //MARK: - No Events Alert View.
    ///Presents the no events alert view.
    func present(noEventsAlertViewWithTitle title: String, andCaption caption: String) {
        self.noEventsTitleLabel.text = title
        self.noEventsCaptionLabel.text = caption
        self.noEventsTitleLabel.textColor = .black
        self.noEventsCaptionLabel.textColor = .darkGray
        self.noEventsAlertView.isHidden = false
    }
    
    ///Dismisses the no events alert view.
    func dismissNoEventsAlertView() {
        self.noEventsAlertView.isHidden = true
    }
    
    //MARK: - Segmented Control.
    ///Called when the segmented control's value changes.
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        self.reloadCollectionView()
        self.collectionView.scrollRectToVisible(.zero, animated: true)
    }
    
    //MARK: - `UICollectionView` functions.
    //Number of sections.
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //Number of cells in a section.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.isSearching {
            return self.filteredSearchEvents.count
        }
        return self.showAll ? self.events.count : self.favoritedEvents.count
    }
    
    //Cell setup.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventCell", for: indexPath) as! EventCollectionViewCell
        cell.setup(withEvent: self.event(forIndex: indexPath.item))
        
        return cell
    }
    
    //Cell size.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = 95
        var width: CGFloat = 0
        //If the device is in landscape, or the device is an iPad, size cells in two columns.
        if !self.isPortrait || UIDevice.current.userInterfaceIdiom == .pad {
            width = (self.collectionView.frame.width - 30) / 2 - 1
        }
        else {
            width = self.collectionView.frame.width - 20
        }
        return CGSize(width: width, height: height)
    }
    
    //Line spacing.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    //Interitem spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    //Highlighting.
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! EventCollectionViewCell
        cell.highlight()
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! EventCollectionViewCell
        cell.unhighlight()
    }
    
    //Selection.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedEvent = self.event(forIndex: indexPath.item)
        self.performSegue(withIdentifier: "showEvent", sender: self)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //Resign search bar first responder.
        self.searchController?.searchBar.resignFirstResponder()
    }
    
    //MARK: - `UISearchBarDelegate`
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //Set `isSearching` to true.
        self.isSearching = true
        
        //Unregister the view controller for previewing, and register the search controller for previewing.
        if let vcPreviewing = self.currentViewControllerPreviewing {
            self.unregisterForPreviewing(withContext: vcPreviewing)
        }
        self.currentViewControllerPreviewing = self.searchController?.registerForPreviewing(with: self, sourceView: self.collectionView)
        
        let searchBarText = searchBar.text ?? ""
        let showAll = self.showAll
        DispatchQueue.global(qos: .background).async {
            self.filteredSearchEvents = self.filterEvents(withSearchText: searchBarText, usingAllEvents: showAll)
            
            //Reload collection view in main thread.
            DispatchQueue.main.async {
                self.reloadCollectionView()
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //Set `isSearching` to false.
        self.isSearching = false
        
        //Remove all events from the filtered search events array.
        self.filteredSearchEvents.removeAll()
        
        //Unregister the search controller for previewing, and register the view controller for previewing.
        if let vcPreviewing = self.currentViewControllerPreviewing {
            self.searchController?.unregisterForPreviewing(withContext: vcPreviewing)
        }
        self.currentViewControllerPreviewing = self.registerForPreviewing(with: self, sourceView: self.collectionView)
        
        //Reload collection view data.
        self.reloadCollectionView()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let showAll = self.showAll
        //Run in background thread.
        DispatchQueue.global(qos: .background).async {
            self.filteredSearchEvents = self.filterEvents(withSearchText: searchText, usingAllEvents: showAll)
            
            //Reload collection view in main thread.
            DispatchQueue.main.async {
                self.reloadCollectionView()
            }
        }
    }
    
    //MARK: - Event filtering.
    private func filterEvents(withSearchText searchText: String, usingAllEvents useAllEvents: Bool) -> [Event] {
        //If search text contains no characters, show all events.
        if searchText == "" {
            return useAllEvents ? self.events : self.favoritedEvents
        }
        
        let lowercasedSearchText = searchText.lowercased()
        
        if useAllEvents {
            return self.events.filter {
                ($0.calendarEvent?.eventSummary?.lowercased().contains(lowercasedSearchText) ?? false) || ($0.calendarEvent?.eventDescription?.lowercased().contains(lowercasedSearchText) ?? false) || ($0.subCategory?.displayTitle.lowercased().contains(lowercasedSearchText) ?? false) || ($0.category.displayTitle.lowercased().contains(lowercasedSearchText))
            }
        }
        return self.favoritedEvents.filter {
            ($0.calendarEvent?.eventSummary?.lowercased().contains(lowercasedSearchText) ?? false) || ($0.calendarEvent?.eventDescription?.lowercased().contains(lowercasedSearchText) ?? false) || ($0.subCategory?.displayTitle.lowercased().contains(lowercasedSearchText) ?? false) || ($0.category.displayTitle.lowercased().contains(lowercasedSearchText))
        }
    }
    
    //MARK: - View controller previewing.
    //Peek.
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = self.collectionView.indexPathForItem(at: location) else {
            return nil
        }
                
        guard let cell = self.collectionView.cellForItem(at: indexPath) else {
            return nil
        }
        
        previewingContext.sourceRect = cell.frame
        
        let event = self.event(forIndex: indexPath.item)
        EventDetailViewController.shared.event = event
        
        return EventDetailViewController.shared
    }
    
    //Pop.
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
    
    //MARK: - Event Retrieval.
    ///Retrieves the correct event, given an index.
    func event(forIndex index: Int) -> Event {
        if self.isSearching {
            return self.filteredSearchEvents[index]
        }
        return self.showAll ? self.events[index] : self.favoritedEvents[index]
    }
    
    //MARK: - Portrait detection.
    ///Returns true if the device is currently portrait.
    var isPortrait: Bool {
        if self.view.frame.width > self.view.frame.height {
            return false
        }
        return true
    }
}

