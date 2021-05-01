//
//  ProfilePictureTableViewCell.swift
//  Messaging
//
//  Created by Lourdes on 4/28/21.
//

import UIKit
import SDWebImage

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
        profilePicture.loadImage(from: viewModel.profilePictureUrl)
        profilePicture.bounds.size = viewModel.profilePicImageViewSize
        profilePicture.setRoundedCorners()
        profilePicture.layer.borderWidth = viewModel.borderWidth
        profilePicture.layer.borderColor = viewModel.borderColor
        guard let email = UserDefaults.standard.value(forKey: StringConstants.shared.userDefaults.email) as? String else {
            signOutUserAndForceCloseApp()
            return
        }
        let profilePicPath = getProfilePicPathFromEmail(email: email)
        StorageManager.shared.downloadUrl(for: profilePicPath) { [weak self] result in
            switch result {
            case .success(let url):
                self?.profilePicture.sd_setImage(with: url, completed: nil)
            case .failure(let error):
                debugPrint("Error Getting Profile Pic Url \(error)")
            }
        }
}
    
    @objc fileprivate func changeImage() {
        
    }
    
    func setupCell() {

    }
}
