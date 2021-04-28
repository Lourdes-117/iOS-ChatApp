//
//  ProfileViewControllerViewModel.swift
//  Messaging
//
//  Created by Lourdes on 4/28/21.
//

import UIKit

enum ProfileViewCells: Int {
    case ProfilePic = 0
    case SignOut = 1
    case none
    
    func getCellIdentifier() -> String {
        switch self {
        case .ProfilePic:
            return ProfilePictureTableViewCell.kIdentifier
        case .SignOut:
            return SignoutTableViewCell.kIdentifier
            
        case .none:
            return ""
        }
    }
}

class ProfileViewControllerViewModel {
    let screenTitle = "Profile"
    let signOut = "Sign Out"
    
    let numberOfSections = 1
}
