//
//  StaffCollectionViewCell.swift
//  KGHS
//
//  Created by Collin DeWaters on 7/18/18.
//  Copyright © 2018 Collin DeWaters. All rights reserved.
//

import UIKit

///`StaffCollectionViewCell`: displays staff found on the server.
class StaffCollectionViewCell: UICollectionViewCell {
    //MARK: - IBOutlets.
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var organizationLabel: UILabel!
    @IBOutlet weak var backgroundShadowView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    
    //MARK: - `UICollectionViewCell` overrides.
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        //Setup corner radius and shadow.
        self.backgroundColor = .clear
        self.unhighlight()
    }
    
    //MARK: - Setup.
    ///Sets up the cell with a staff member.
    func setup(withStaffMember staffMember: Staff) {
        self.nameLabel.text = staffMember.name ?? "No Name"
        var organizationLabelText = staffMember.departmentValue?.displayTitle ?? "No Subject"
        
        if let organization = staffMember.organization {
            organizationLabelText += " • \(organization)"
        }
    }
    
    ///MARK: - Highlighting.
    ///Highlights the cell.
    func highlight() {
        self.backgroundShadowView.alpha = 0.7
        self.backgroundShadowView.layer.cornerRadius = 15
        self.layer.shadowOpacity = 0
    }
    
    ///Unhighlights the cell.
    func unhighlight() {
        self.backgroundShadowView.alpha = 1
        self.backgroundShadowView.layer.cornerRadius = 15
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 4.0
    }

}
