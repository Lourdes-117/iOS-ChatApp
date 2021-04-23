//
//  Constants.swift
//  Messaging
//
//  Created by Lourdes on 4/22/21.
//
import Foundation

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
    let regex = Regex()
}

///Use Through StringConstants shared Instance
struct UserDefaultConstants {
    let loggedIn = "loggedIn"
}

///Use Through StringConstants shared Instance
struct Regex {
    let email = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let strongPassword = "^(?=.*[a-z])(?=.*[A-Z])((?=.*[0-9])|(?=.*[!@#$%^&*])).{8,}$"
}
