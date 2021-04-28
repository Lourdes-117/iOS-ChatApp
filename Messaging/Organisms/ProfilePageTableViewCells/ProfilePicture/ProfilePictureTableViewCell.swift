//
//  ProfilePictureTableViewCell.swift
//  Messaging
//
//  Created by Lourdes on 4/28/21.
//

import UIKit

class ProfilePictureTableViewCell: UITableViewCell {
    static let kIdentifier = "ProfilePictureTableViewCell"
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupCell() {
        layoutSubviews()
        layoutIfNeeded()
        self.profilePicture.setRoundedCorners()
        profilePicture.setRoundedCorners()
        profilePicture.layer.borderColor = UIColor.black.cgColor
        layoutSubviews()
        layoutIfNeeded()
    }
}
