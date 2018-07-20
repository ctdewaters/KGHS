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
    
    //MARK: - Properties.
    ///The retrieved events to display.
    var events = [Event]()
    
    ///The filtered search events to display.
    var filteredSearchEvents = [Event]()
    
    ///If true, the user is currently searching events.
    var isSearching: Bool = false
    
    ///The search controller.
    var searchController: UISearchController?
    
    ///The selected event, set after cell selection.
    var selectedEvent: Event?

    //MARK: - `UIViewController` overrides.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Setup activity indicator.
        self.activityIndicator.color = .blueTheme
        self.activityIndicator.type = .orbit
        
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        //Setup the search controller.
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController?.dimsBackgroundDuringPresentation = false
        self.searchController?.searchBar.tintColor = .blueTheme
        self.searchController?.searchBar.delegate = self
        self.searchController?.hidesNavigationBarDuringPresentation = false
        self.navigationItem.searchController = self.searchController
        
        //Register for view controller previewing.
        self.registerForPreviewing(with: self, sourceView: self.collectionView)
        
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
    func reload() {
        //Animate activity indicator.
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()

        //Retrive the events.
        Event.retrieve { (retrievedEvents) in
            //Unwrap the retreived events array.
            if let retrievedEvents = retrievedEvents {
                self.events = retrievedEvents
                self.collectionView.reloadData()
                
                //Deactivate activity indicator
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    
    //MARK: - `UICollectionView` functions.
    //Number of sections.
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //Number of cells in a section.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.isSearching ? self.filteredSearchEvents.count : self.events.count
    }
    
    //Cell setup.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventCell", for: indexPath) as! EventCollectionViewCell
        cell.setup(withEvent: self.isSearching ? self.filteredSearchEvents[indexPath.item] : self.events[indexPath.item])
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
        self.selectedEvent = self.isSearching ? self.filteredSearchEvents[indexPath.item] : self.events[indexPath.item]
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
        
        let searchBarText = searchBar.text ?? ""
        DispatchQueue.global(qos: .background).async {
            self.filteredSearchEvents = self.filterEvents(withSearchText: searchBarText)
            
            //Reload collection view in main thread.
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //Set `isSearching` to false.
        self.isSearching = false
        
        //Remove all events from the filtered search events array.
        self.filteredSearchEvents.removeAll()
        
        //Reload collection view data.
        self.collectionView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //Run in background thread.
        DispatchQueue.global(qos: .background).async {
            self.filteredSearchEvents = self.filterEvents(withSearchText: searchText)
            
            //Reload collection view in main thread.
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    //MARK: - Event filtering.
    private func filterEvents(withSearchText searchText: String) -> [Event] {
        //If search text contains no characters, show all events.
        if searchText == "" {
            return self.events
        }
        
        let lowercasedSearchText = searchText.lowercased()
        return self.events.filter {
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
        
        let event = self.isSearching ? self.filteredSearchEvents[indexPath.item] : self.events[indexPath.item]
        EventDetailViewController.shared.event = event
        
        return EventDetailViewController.shared
    }
    
    //Pop.
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.navigationController?.pushViewController(viewControllerToCommit, animated: true)
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

