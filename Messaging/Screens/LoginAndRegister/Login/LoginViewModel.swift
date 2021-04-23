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
    
    var pageTitle: String {
        isOnLoginPage ? loginTitle : registerTitle
    }
    var buttonTitle: String {
        isOnLoginPage ? registerTitle : loginTitle
    }
    var shouldHideLoginPage: Bool {
        isOnLoginPage ? false : true
    }
    var shouldHideRegisterPage: Bool {
        isOnLoginPage ? true : false
    }
}
