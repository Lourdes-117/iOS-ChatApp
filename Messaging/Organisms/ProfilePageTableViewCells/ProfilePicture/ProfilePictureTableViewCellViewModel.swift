//
//  ProfilePictureTableViewCellViewModel.swift
//  Messaging
//
//  Created by Lourdes on 4/28/21.
//

import UIKit

class ProfilePictureTableViewCellViewModel {
    let borderWidth: CGFloat = 2
    let borderColor = UIColor.lightGray.cgColor
    var userName: String {
        let firstName = UserDefaults.standard.value(forKey: StringConstants.shared.userDefaults.firstName) as? String
        let lastName = UserDefaults.standard.value(forKey: StringConstants.shared.userDefaults.lastName) as? String
        return "\(firstName ?? "") \(lastName ?? "")"
    }
    
    var profilePictureUrl: String? {
        let profilePicUrl = UserDefaults.standard.value(forKey: StringConstants.shared.userDefaults.profilePicurl) as? String
        return profilePicUrl
    }
    
    var profilePicImageViewSize: CGSize {
        CGSize(width: UIScreen.main.bounds.width * 0.6, height: UIScreen.main.bounds.width * 0.6)
    }
}
