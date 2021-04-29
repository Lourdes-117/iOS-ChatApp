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
    let storage = StorageConstants()
}

///Use Through StringConstants shared Instance
struct DatabaseConstants {
    let users = "users"
    let name = "name"
    let safeEmail = "safe_email"
    let firstName = "first_name"
    let lastName = "last_name"
    let conversations = "conversations"
    let messageId = "messageId"
    let otherUserEmail = "other_user_email"
    let latestMessage = "latest_message"
    let date = "date"
    let message = "message"
    let isRead = "isRead"
}

///Use Through StringConstants shared Instance
struct UserDefaultConstants {
    let profilePicurl = "profile_picture_url"
    let email = "email_address"
    let firstName = "first_name"
    let lastName = "last_name"
}

///Use Through StringConstants shared Instance
struct StorageConstants {
    let imagesPath = "images/"
    let profilePicture = "_profile_picture.png"
}

///Use Through StringConstants shared Instance
struct Regex {
    let email = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let strongPassword = "^(?=.*[a-z])(?=.*[A-Z])((?=.*[0-9])|(?=.*[!@#$%^&*])).{8,24}$"
    let nameSupportingAscii = "(?<! )[-a-zA-Z' ]{2,26}"
}
