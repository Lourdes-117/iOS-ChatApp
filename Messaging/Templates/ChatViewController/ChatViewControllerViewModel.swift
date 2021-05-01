//
//  ChatViewControllerViewModel.swift
//  Messaging
//
//  Created by Lourdes on 4/26/21.
//

import Foundation
import MessageKit

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

extension MessageKind {
    var rawValue: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "link_preview"
        case .custom(_):
            return "custom"
        }
    }
}

struct Sender: SenderType {
    var senderId: String
    var displayName: String
    var photoUrl: String
}

class ChatViewControllerViewModel {
    var isNewConversation = true
    var receiverName: String = ""
    var receiverEmail: String = ""
    var conversationID: String?
    let senderEmail = UserDefaults.standard.value(forKey: StringConstants.shared.userDefaults.email)
    
    var selfSender: Sender? {
        guard let email = senderEmail as? String else { return nil }
        let profilePicurl = UserDefaults.standard.value(forKey: StringConstants.shared.userDefaults.profilePicurl) as? String ?? ""
        let firstName = UserDefaults.standard.value(forKey: StringConstants.shared.userDefaults.firstName) as? String
        let lastName = UserDefaults.standard.value(forKey: StringConstants.shared.userDefaults.lastName)  as? String
        let fullName = (firstName ?? "") + (lastName ?? "")
        return Sender(senderId: email, displayName: fullName, photoUrl: profilePicurl)
    }
    
    func generateMessageID() -> String? {
        let dateString = Date().timeIntervalSince1970.description.replacingOccurrences(of: ".", with: "")
        guard let senderEmail = senderEmail else { return nil }
        let messageId = "conversation_\(receiverEmail)_\(dateString)_\(senderEmail)".replacingOccurrences(of: " ", with: "")
        debugPrint("Generated Message ID: \(messageId)")
        return messageId
    }
}
