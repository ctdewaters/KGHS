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
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return UICollectionReusableView()
    }
    
    //Cell setup.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}

