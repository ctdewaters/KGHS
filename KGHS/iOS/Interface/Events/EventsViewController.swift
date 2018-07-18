//
//  FirstViewController.swift
//  KGHS
//
//  Created by Collin DeWaters on 2/21/18.
//  Copyright © 2018 Collin DeWaters. All rights reserved.
//

import UIKit

///`EventsViewController`: View Controller which displays events retrieved from the school's iCal feed, and the user's favorited events.
class EventsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //MARK: - IBOutlets.
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - Properties.
    ///The retrieved events to display.
    var events = [Event]()

    //MARK: - `UIViewController` overrides.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.collectionView.contentInset.top = 15
        
        self.reload()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Apperance setup.
        self.tabBarController?.tabBar.barStyle = .default
        self.tabBarController?.tabBar.tintColor = .blueTheme
        UIApplication.shared.statusBarStyle = .default
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Reloading.
    func reload() {
        //Retrive the events.
        Event.retrieve { (retrievedEvents) in
            //Unwrap the retreived events array.
            if let retrievedEvents = retrievedEvents {
                self.events = retrievedEvents
                self.collectionView.reloadData()
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
        return self.events.count
    }
    
    //Cell setup.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventCell", for: indexPath) as! EventCollectionViewCell
        cell.setup(withEvent: self.events[indexPath.item])
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
    
    //MARK: - Portrait detection.
    ///Returns true if the device is currently portrait.
    var isPortrait: Bool {
        if self.view.frame.width > self.view.frame.height {
            return false
        }
        return true
    }
}

