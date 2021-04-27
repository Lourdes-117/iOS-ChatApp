//
//  LoginViewModel.swift
//  Messaging
//
//  Created by Lourdes on 4/23/21.
//

import UIKit
struct ChatAppUserModel {
    let firstName: String
    let lastName: String
    let emailAddress: String
    
    var profilePictureFileName: String {
        return "\(DatabaseManager.getSafeEmail(from: emailAddress))\(StringConstants.shared.storage.profilePicture)"
    }
}

class LoginControllerViewModel {
    var isOnLoginPage = true
    private let loginTitle = "Log In"
    private let registerTitle = "Register"
    let formInvalidAlertTitle = "Whoops!"
    let formInvalidAlertMessage = "Please Enter All Information To Continue"
    let alertDismissMessage = "Dismiss"
    let profilePicSelectionTitle = "Profile Picture"
    let profilePicSelectionMessage = "How Would You Like To Select Your Picture"
    let cancel = "Cancel"
    let takePhoto = "Take Photo"
    let choosePhoto = "Choose Photo"
    let userExistsTitle = "User Exists"
    let userExistsMessage = "Looks like An Account For That Email Already exists"
    let error = "Error"
    let pleaseTryAgain = "Please Try Again"
    
    var pageTitle: String {
        isOnLoginPage ? loginTitle : registerTitle
    }
    var loginRegisterSwitchButtonTitle: String {
        isOnLoginPage ? registerTitle : loginTitle
    }
    var shouldHideLoginPage: Bool {
        isOnLoginPage ? false : true
    }
    var shouldHideRegisterPage: Bool {
        isOnLoginPage ? true : false
    }
}
