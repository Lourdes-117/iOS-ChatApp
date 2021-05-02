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
            return StringConstants.shared.messageKind.text
        case .attributedText(_):
            return StringConstants.shared.messageKind.attributedText
        case .photo(_):
            return StringConstants.shared.messageKind.photo
        case .video(_):
            return StringConstants.shared.messageKind.video
        case .location(_):
            return StringConstants.shared.messageKind.location
        case .emoji(_):
            return StringConstants.shared.messageKind.emoji
        case .audio(_):
            return StringConstants.shared.messageKind.audio
        case .contact(_):
            return StringConstants.shared.messageKind.contact
        case .linkPreview(_):
            return StringConstants.shared.messageKind.linkPreview
        case .custom(_):
            return StringConstants.shared.messageKind.custom
        }
    }
}

struct Sender: SenderType {
    var senderId: String
    var displayName: String
    var photoUrl: String
}

struct Media: MediaItem {
    var url: URL?
    
    var image: UIImage?
    
    var placeholderImage: UIImage
    
    var size: CGSize
    
    
}

class ChatViewControllerViewModel {
    // Input View
    let inputBarButtonIcon = UIImage(systemName: "plus")
    let attachMediaTitle = "Attach Media"
    let attachMediaMessage = "What Would You Like To Attach"
    let photo = "Photo"
    let video = "Video"
    let audio = "Audio"
    let cancel = "Cancel"
    
    // Attaching Media
    let attachPhotoTitle = "Attach Photo"
    let attachPhotoMessage = "Where Would You Like To Attach Photo From"
    let camera = "Camera"
    let photoLibrary = "Photo Library"
    
    // Segue Identifiers
    let imageViewerSegueIdentifier = "ImageViewerViewControllerSegue"
    
    // Selected Message
    var selectedImageUrl: URL?
    
    // Accounts
    var receiverName: String = ""
    var receiverEmail: String = ""
    var conversationID: String?
    var isNewConversation: Bool {
        return conversationID == nil
    }
    let senderEmail = UserDefaults.standard.value(forKey: StringConstants.shared.userDefaults.email) as? String
    let senderName = UserDefaults.standard.value(forKey: StringConstants.shared.userDefaults.name) as? String ?? ""
    
    var selfSender: Sender? {
        guard let email = senderEmail else { return nil }
        let profilePicurl = getProfilePicPathFromEmail(email: email)
        let fullName = senderName
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
