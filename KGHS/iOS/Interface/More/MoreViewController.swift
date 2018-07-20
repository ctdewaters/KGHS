//
//  MoreViewController.swift
//  KGHS
//
//  Created by Collin DeWaters on 7/19/18.
//  Copyright © 2018 Collin DeWaters. All rights reserved.
//

import UIKit

class MoreViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    //MARK: - IBOutlets.
    @IBOutlet weak var collectionView: UICollectionView!
    

    //MARK: - `UIViewController` overrides.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = .blueTheme
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

    
    //MARK: - `UICollectionView`
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }

}
