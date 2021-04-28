//
//  ProfilePictureTableViewCellViewModel.swift
//  Messaging
//
//  Created by Lourdes on 4/28/21.
//

import Foundation

class ProfilePictureTableViewCellViewModel {
    var userName: String {
        let firstName = UserDefaults.standard.value(forKey: StringConstants.shared.userDefaults.firstName) as? String
        let lastName = UserDefaults.standard.value(forKey: StringConstants.shared.userDefaults.lastName) as? String
        return "\(firstName ?? "") \(lastName ?? "")"
    }
}
