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
    let messageKind = MessageKindConstant()
    let regex = Regex()
    let storage = StorageConstants()
}

///Use Through StringConstants shared Instance
struct DatabaseConstants {
    //Account
    let users = "users"
    let name = "name"
    let safeEmail = "safe_email"
    let firstName = "first_name"
    let lastName = "last_name"
    
    //Message
    let conversations = "conversations"
    let messageId = "messageId"
    let otherUserName = "other_user_name"
    let otherUserEmail = "other_user_email"
    let latestMessage = "latest_message"
    let messageType = "type"
    let content = "content"
    let senderEmail = "sender_email"
    let date = "date"
    let message = "message"
    let messagesArray = "messages"
    let isRead = "isRead"
}

///Use Through StringConstants shared Instance
struct UserDefaultConstants {
    let profilePicurl = "profile_picture_url"
    let email = "email_address"
    let name = "first_name"
}

///Use Through StringConstants shared Instance
struct MessageKindConstant {
    let text = "text"
    let attributedText = "attributedText"
    let photo = "photo"
    let video = "video"
    let location = "location"
    let emoji = "emoji"
    let audio = "audio"
    let contact = "contact"
    let linkPreview = "linkPreview"
    let custom = "custom"
}

///Use Through StringConstants shared Instance
struct StorageConstants {
    let profilePicturesPath = "profile_pictures/"
    let profilePicture = "_profile_picture.png"
    let messageImagesPath = "message_images/"
    let messageVideosPath = "message_videos/"
    let messageImageExtension = "_image.jpg"
    let messageVideoExtension = "_video.mov"
}

///Use Through StringConstants shared Instance
struct Regex {
    let email = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let strongPassword = "^(?=.*[a-z])(?=.*[A-Z])((?=.*[0-9])|(?=.*[!@#$%^&*])).{8,24}$"
    let nameSupportingAscii = "(?<! )[-a-zA-Z' ]{2,26}"
}
