//
//  Constants.swift
//  Messaging
//
//  Created by Lourdes on 4/22/21.
//
import Foundation

let kAnimationDuration: TimeInterval = 0.25

class StringConstants {
    private static var instance: StringConstants?
    private init() {}
    public static var shared: StringConstants {
        guard let instanceVariable = instance else {
            instance = StringConstants()
            return instance ?? StringConstants()
        }
        return instanceVariable
    }
    
    //Constants
    let userDefaults = UserDefaultConstants()
    let database = DatabaseConstants()
    let regex = Regex()
}

///Use Through StringConstants shared Instance
struct DatabaseConstants {
    let firstName = "first_name"
    let lastName = "last_name"
}

///Use Through StringConstants shared Instance
struct UserDefaultConstants {
    let profilePicurl = "profile_picture_url"
    let email = "email_address"
    let firstName = "first_name"
    let lastName = "last_name"
}

///Use Through StringConstants shared Instance
struct Regex {
    let email = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let strongPassword = "^(?=.*[a-z])(?=.*[A-Z])((?=.*[0-9])|(?=.*[!@#$%^&*])).{8,24}$"
    let nameSupportingAscii = "(?<! )[-a-zA-Z' ]{2,26}"
}
