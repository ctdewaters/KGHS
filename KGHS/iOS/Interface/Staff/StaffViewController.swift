//
//  SecondViewController.swift
//  KGHS
//
//  Created by Collin DeWaters on 2/21/18.
//  Copyright © 2018 Collin DeWaters. All rights reserved.
//

import UIKit

///`StaffViewController`: View controller class which displays the school's staff directory, and favorited staff.
class StaffViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    //MARK: - IBOutlets.
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - Properties.
    ///The fetched staff dictionary.
    private var fetchedStaff = [Staff.Department: [Staff]]()
    
    ///The array of dictionary keys, in the order to be displayed.
    private var fetchedStaffKeys = [Staff.Department]()
    
    //MARK: - `UIViewController` overrides.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.reload()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
        Staff.retrieveAll { (serverStaff, serverDepartments) in
            guard let serverStaff = serverStaff, let serverDepartments = serverDepartments else {
                self.fetchedStaffKeys.removeAll()
                self.fetchedStaff.removeAll()
                return
            }
            
            self.fetchedStaff = serverStaff
            self.fetchedStaffKeys = serverDepartments
            
            self.collectionView.reloadData()
        }
    }

    //MARK: - `UICollectionView` functions.
    //Number of sections.
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.fetchedStaff.keys.count
    }
    
    //Number of cells in a section.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fetchedStaff[self.fetchedStaffKeys[section]]?.count ?? 0
    }
    
    //Header view.
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        return UICollectionReusableView()
//    }
    
    //Cell setup.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "staffCell", for: indexPath) as! StaffCollectionViewCell
        if let staffMember = self.fetchedStaff[fetchedStaffKeys[indexPath.section]]?[indexPath.item] {
            cell.setup(withStaffMember: staffMember)
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
    
    //MARK: - Portrait detection.
    ///Returns true if the device is currently portrait.
    var isPortrait: Bool {
        if self.view.frame.width > self.view.frame.height {
            return false
        }
        return true
    }

}

