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
class StaffViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    //MARK: - IBOutlets.
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    
    //MARK: - Properties.
    ///The fetched staff dictionary.
    private var fetchedStaff = [Staff.Department: [Staff]]()
    
    ///The array of dictionary keys, in the order to be displayed.
    private var fetchedStaffKeys = [Staff.Department]()
    
    ///The filtered search staff to display.
    var filteredSearchStaff = [Staff.Department: [Staff]]()
    
    ///The filtered search staff departments to display.
    var filteredSearchStaffKeys = [Staff.Department]()
    
    ///If true, the user is currently searching events.
    var isSearching: Bool = false

    
    ///The search controller.
    private var searchController: UISearchController?
    
    //MARK: - `UIViewController` overrides.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup the search controller.
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController?.dimsBackgroundDuringPresentation = false
        self.searchController?.searchBar.tintColor = .yellowTheme
        self.searchController?.searchBar.delegate = self
        self.searchController?.hidesNavigationBarDuringPresentation = false
        self.navigationItem.searchController = self.searchController
        
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
            
            self.collectionView.reloadData()
            
            //Remove activity indicator.
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        }
    }

    //MARK: - `UICollectionView` functions.
    //Number of sections.
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.isSearching ? self.filteredSearchStaff.keys.count : self.fetchedStaff.keys.count
    }
    
    //Number of cells in a section.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.isSearching ? self.filteredSearchStaff[self.filteredSearchStaffKeys[section]]?.count ?? 0 : self.fetchedStaff[self.fetchedStaffKeys[section]]?.count ?? 0
    }
    
    //Header view.
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        return UICollectionReusableView()
//    }
    
    //Cell setup.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "staffCell", for: indexPath) as! StaffCollectionViewCell
        
        if self.isSearching {
            //Retreive the staff member from the filtered collections.
            if let staffMember = self.filteredSearchStaff[self.filteredSearchStaffKeys[indexPath.section]]?[indexPath.item] {
                cell.setup(withStaffMember: staffMember)
            }
        }
        else {
            //Not searching.
            if let staffMember = self.fetchedStaff[self.fetchedStaffKeys[indexPath.section]]?[indexPath.item] {
                cell.setup(withStaffMember: staffMember)
            }
        }
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
        
        let searchBarText = searchBar.text ?? ""
        DispatchQueue.global(qos: .background).async {
            let filteredData = self.filterStaff(withSearchText: searchBarText)
            
            //Set the filtered collections to the filtered data.
            self.filteredSearchStaffKeys = filteredData.keys
            self.filteredSearchStaff = filteredData.staff

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
        self.filteredSearchStaff.removeAll()
        self.filteredSearchStaffKeys.removeAll()
        
        //Reload collection view data.
        self.collectionView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //Run in background thread.
        DispatchQueue.global(qos: .background).async {
            let filteredData = self.filterStaff(withSearchText: searchText)
            
            //Set the filtered collections to the filtered data.
            self.filteredSearchStaffKeys = filteredData.keys
            self.filteredSearchStaff = filteredData.staff
            
            //Reload collection view in main thread.
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    //MARK: - Event filtering.
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

    //MARK: - Portrait detection.
    ///Returns true if the device is currently portrait.
    var isPortrait: Bool {
        if self.view.frame.width > self.view.frame.height {
            return false
        }
        return true
    }

}

