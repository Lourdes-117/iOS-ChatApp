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
    
    let viewModel = ProfilePictureTableViewCellViewModel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        initialSetup()
    }
    
    fileprivate func initialSetup() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(changeImage))
        profilePicture.addGestureRecognizer(gesture)
        userName.text = viewModel.userName
    }
    
    @objc fileprivate func changeImage() {
        
    }
    
    func setupCell() {

    }
}
