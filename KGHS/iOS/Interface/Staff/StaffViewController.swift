//
//  SecondViewController.swift
//  KGHS
//
//  Created by Collin DeWaters on 2/21/18.
//  Copyright © 2018 Collin DeWaters. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

///`StaffViewController`: View controller class which displays the school's staff directory, and favorited staff.
class StaffViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UIViewControllerPreviewingDelegate {
    //MARK: - IBOutlets.
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    @IBOutlet weak var showFavoritesSegmentedControl: UISegmentedControl!
    
    //MARK: - Properties.
    ///The fetched staff dictionary.
    var fetchedStaff = [Staff.Department: [Staff]]()
    
    ///The array of dictionary keys, in the order to be displayed.
    var fetchedStaffKeys = [Staff.Department]()
    
    ///The favorited staff members.
    var favoritedStaff = [Staff]()
    
    ///The filtered favorited staff.
    var filteredFavoritedStaff = [Staff]()
    
    ///The filtered search staff to display.
    var filteredSearchStaff = [Staff.Department: [Staff]]()
    
    ///The filtered search staff departments to display.
    var filteredSearchStaffKeys = [Staff.Department]()
    
    ///If true, the user is currently searching events.
    var isSearching: Bool = false
    
    ///The selected staff member.
    var selectedStaffMember: Staff?
    
    ///The search controller.
    private var searchController: UISearchController?
    
    ///The view controller previewing object.
    var currentViewControllerPreviewing: UIViewControllerPreviewing?
    
    var showAll: Bool {
        if self.showFavoritesSegmentedControl.selectedSegmentIndex == 0 {
            return true
        }
        return false
    }
    
    ///The global instance.
    public static var global: StaffViewController?
    
    //MARK: - `UIViewController` overrides.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        StaffViewController.global = self
        
        self.navigationController?.navigationBar.tintColor = .yellowTheme
        
        //Setup the search controller.
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController?.dimsBackgroundDuringPresentation = false
        self.searchController?.searchBar.tintColor = .yellowTheme
        self.searchController?.searchBar.delegate = self
        self.searchController?.hidesNavigationBarDuringPresentation = false
        self.definesPresentationContext = true
        self.navigationItem.searchController = self.searchController
        
        //Register for previewing.
        self.currentViewControllerPreviewing = self.registerForPreviewing(with: self, sourceView: self.collectionView)
        
        //Setup activity indicator.
        self.activityIndicator.color = .blueTheme
        self.activityIndicator.type = .orbit

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
        self.hideHairline()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Reset navigation bar.
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationItem.hidesSearchBarWhenScrolling = true
        
        self.tabBarController?.tabBar.barStyle = .black
        self.tabBarController?.tabBar.tintColor = .yellowTheme
        UIApplication.shared.statusBarStyle = .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showStaffMember" {
            let destination = segue.destination as! StaffDetailViewController
            destination.staffMember = self.selectedStaffMember
        }
    }
    
    //MARK: - Reloading.
    func reload() {
        //Animate activity indicator.
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        
        Staff.retrieveAll { (serverStaff, serverDepartments) in
            guard let serverStaff = serverStaff, let serverDepartments = serverDepartments else {
                //Remove activity indicator.
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                
                return
            }
            
            self.fetchedStaff = serverStaff
            self.fetchedStaffKeys = serverDepartments
            
            self.reloadCollectionView()
            
            //Filter favorited staff.
            DispatchQueue.global(qos: .background).async {
                
                var filteredFavoriteStaff = [Staff]()
                for key in self.fetchedStaffKeys {
                    let staffArray = self.fetchedStaff[key]!
                    filteredFavoriteStaff.append(contentsOf: staffArray.filter {
                        $0.isFavorited
                    })
                }
                self.favoritedStaff = filteredFavoriteStaff
            }
            
            //Remove activity indicator.
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        }
    }
    
    ///Reloads the collection view with preretrieved data.
    func reloadCollectionView() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            
//            if !self.showAll && self.favoritedEvents.count == 0 {
//                //Show no favorited events alert.
//                self.present(noEventsAlertViewWithTitle: "No Favorited Events", andCaption: "Tap the star icon after selecting an event to favorite it.")
//            }
//            else if !self.isLoading && self.showAll && self.events.count == 0  {
//                self.present(noEventsAlertViewWithTitle: "No Events Found", andCaption: "Could not retrieve calendar events. Please try again.")
//            }
//            else {
//                self.dismissNoEventsAlertView()
//            }
        }
    }

    
    //MARK: - Segmented Control.
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        self.reloadCollectionView()
    }
    

    //MARK: - `UICollectionView` functions.
    //Number of sections.
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if self.showAll {
            return self.isSearching ? self.filteredSearchStaff.keys.count : self.fetchedStaff.keys.count
        }
        return 1
    }
    
    //Number of cells in a section.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.showAll {
            return self.isSearching ? self.filteredSearchStaff[self.filteredSearchStaffKeys[section]]?.count ?? 0 : self.fetchedStaff[self.fetchedStaffKeys[section]]?.count ?? 0
        }
        return self.isSearching ? self.filteredFavoritedStaff.count : self.favoritedStaff.count
    }
    
    //Header view.
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        return UICollectionReusableView()
//    }
    
    //Cell setup.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "staffCell", for: indexPath) as! StaffCollectionViewCell
        
        cell.setup(withStaffMember: self.staffMember(forIndexPath: indexPath))
        return cell
    }
    
    //Cell size.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = 70
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
        let cell = collectionView.cellForItem(at: indexPath) as! StaffCollectionViewCell
        cell.highlight()
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! StaffCollectionViewCell
        cell.unhighlight()
    }
    
    //Selection.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedStaffMember = self.staffMember(forIndexPath: indexPath)
        self.performSegue(withIdentifier: "showStaffMember", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //Resign search bar first responder.
        self.searchController?.searchBar.resignFirstResponder()
    }
    
    //MARK: - `UISearchBarDelegate`
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //Set `isSearching` to true.
        self.isSearching = true
        
        //Update view controller previewing.
        self.unregisterForPreviewing(withContext: self.currentViewControllerPreviewing!)
        self.currentViewControllerPreviewing = self.searchController?.registerForPreviewing(with: self, sourceView: self.collectionView)
        
        let searchBarText = searchBar.text ?? ""
        
        let showAll = self.showAll
        DispatchQueue.global(qos: .background).async {
            if showAll {
                let filteredData = self.filterStaff(withSearchText: searchBarText)
                
                //Set the filtered collections to the filtered data.
                self.filteredSearchStaffKeys = filteredData.keys
                self.filteredSearchStaff = filteredData.staff
            }
            else {
                self.filteredFavoritedStaff = self.filterFavoritedStaff(withSearchText: searchBarText)
            }

            //Reload collection view.
            self.reloadCollectionView()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //Set `isSearching` to false.
        self.isSearching = false
        
        //Update view controller previewing.
        self.searchController?.unregisterForPreviewing(withContext: self.currentViewControllerPreviewing!)
        self.currentViewControllerPreviewing = self.registerForPreviewing(with: self, sourceView: self.collectionView)
        
        //Remove all events from the filtered search events array.
        self.filteredSearchStaff.removeAll()
        self.filteredSearchStaffKeys.removeAll()
        
        //Reload collection view data.
        self.reloadCollectionView()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let showAll = self.showAll
        
        //Run in background thread.
        DispatchQueue.global(qos: .background).async {
            if showAll {
                let filteredData = self.filterStaff(withSearchText: searchText)
                
                //Set the filtered collections to the filtered data.
                self.filteredSearchStaffKeys = filteredData.keys
                self.filteredSearchStaff = filteredData.staff
            }
            else {
                self.filteredFavoritedStaff = self.filterFavoritedStaff(withSearchText: searchText)
            }

            //Reload collection view in main thread.
            self.reloadCollectionView()
        }
    }
    
    //MARK: - Staff filtering.
    private func filterStaff(withSearchText searchText: String) -> (staff: [Staff.Department: [Staff]], keys: [Staff.Department]) {
        //If search text contains no characters, show all events.
        if searchText == "" {
            return (staff: self.fetchedStaff, keys: self.fetchedStaffKeys)
        }
        
        let lowercasedSearchText = searchText.lowercased()
        
        //Staff and key collections to store the filtered results in.
        var staff = [Staff.Department: [Staff]]()
        var keys = [Staff.Department]()
        
        //Iterate through the fetched staff keys to filter the staff members.
        for key in self.fetchedStaffKeys {
            if let fetchedStaffArray = self.fetchedStaff[key] {
                
                //Filter staff members.
                let filteredDepartmentStaffArray = fetchedStaffArray.filter {
                    $0.name?.lowercased().contains(lowercasedSearchText) ?? false
                }
                
                if filteredDepartmentStaffArray.count > 0 {
                    keys.append(key)
                    staff[key] = filteredDepartmentStaffArray
                }
            }
        }
        
        return (staff: staff, keys: keys)
    }
    
    private func filterFavoritedStaff(withSearchText searchText: String) -> [Staff] {
        //If search text contains no characters, show all events.
        if searchText == "" {
            return self.favoritedStaff
        }
        
        let lowercasedSearchText = searchText.lowercased()
        
        return favoritedStaff.filter {
            $0.name?.lowercased().contains(lowercasedSearchText) ?? false
        }
    }
    
    //MARK: - `UIViewControllerPreviewingDelegate`.
    //Peek.
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = self.collectionView.indexPathForItem(at: location) else {
            return nil
        }
        
        guard let cell = self.collectionView.cellForItem(at: indexPath) else {
            return nil
        }
        
        previewingContext.sourceRect = cell.frame
        
        StaffDetailViewController.shared.staffMember = self.staffMember(forIndexPath: indexPath)

        return StaffDetailViewController.shared
    }
    
    //Pop.
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
    
    //MARK: - Staff Member Retrieval.
    ///Retrieves a staff member, given an index.
    func staffMember(forIndexPath indexPath: IndexPath) -> Staff {
        if self.isSearching {
            if self.showAll {
                let key = self.filteredSearchStaffKeys[indexPath.section]
                return self.filteredSearchStaff[key]![indexPath.item]
            }
            return self.filteredFavoritedStaff[indexPath.item]
        }
        else if self.showAll {
            let key = self.fetchedStaffKeys[indexPath.section]
            return self.fetchedStaff[key]![indexPath.item]
        }
        return self.favoritedStaff[indexPath.item]
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
