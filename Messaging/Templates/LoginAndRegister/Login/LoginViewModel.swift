//
//  LoginViewModel.swift
//  Messaging
//
//  Created by Lourdes on 4/23/21.
//

import UIKit

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
