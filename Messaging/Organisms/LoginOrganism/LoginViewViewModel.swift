//
//  LoginViewViewModel.swift
//  Messaging
//
//  Created by Lourdes on 4/23/21.
//

import UIKit

class LoginViewViewModel {
    let textFieldBorderWidth: CGFloat = 1
    let textFieldBorderRadius: CGFloat = 8
    let textFieldBorderColor: CGColor = UIColor.lightGray.cgColor
    
    let yellowColor: CGColor = UIColor.yellow.cgColor
    let greenColor: CGColor = UIColor.green.cgColor
    let redColor: CGColor = UIColor.red.cgColor
    
    func isEmailValid(_ email: String) -> Bool {
        return email.matchesRegex(StringConstants.shared.regex.email)
    }
    
    func getEmailBorderColor(forString email: String) -> CGColor {
        isEmailValid(email) ? greenColor : redColor
    }
    
    func getPasswordBorderColor(forString password: String) -> CGColor {
        if password.matchesRegex(StringConstants.shared.regex.strongPassword) {
            return greenColor
        } else if password.hasUpperCase && password.hasLowerCase {
            return yellowColor
        } else {
            return redColor
        }
    }
}
