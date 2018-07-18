//
//  EventCollectionViewCell.swift
//  KGHS
//
//  Created by Collin DeWaters on 7/18/18.
//  Copyright © 2018 Collin DeWaters. All rights reserved.
//

import UIKit

///`EventCollectionViewCell`: displays an event in the collection view in the `EventsViewController`.
class EventCollectionViewCell: UICollectionViewCell {
    //MARK: - IBOutlets.
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var calendarLabel: UILabel!
    @IBOutlet weak var backgroundShadowView: UIView!
    
    
    //MARK: - `UICollectionViewCell` overrides.
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        //Setup corner radius and shadow.
        self.backgroundColor = .clear
        self.unhighlight()
    }
    
    //MARK: - Setup.
    ///Sets this cell with an `Event` object.
    func setup(withEvent event: Event) {
        self.titleLabel.text = event.calendarEvent?.eventSummary ?? "No Title"
        self.categoryImageView.image = event.subCategory?.icon ?? ((event.category == .athletics) ? UIImage(named: "athletics") : UIImage(named: "academics"))
        var calendarLabelText = event.category.displayTitle
        
        if let subCategory = event.subCategory {
            calendarLabelText = calendarLabelText + " • \(subCategory.displayTitle)"
        }
        self.calendarLabel.text = calendarLabelText
    }
    
    //MARK: - Highlighting.
    ///Highlights the cell.
    func highlight() {
        self.backgroundShadowView.backgroundColor = .lightGray
        self.backgroundShadowView.layer.cornerRadius = 15
        self.layer.shadowOpacity = 0
    }
    
    ///Unhighlights the cell.
    func unhighlight() {
        self.backgroundShadowView.backgroundColor = .white
        self.backgroundShadowView.layer.cornerRadius = 15
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowOpacity = 0.3
        self.layer.shadowRadius = 4.0
    }
}
