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

struct Sender: SenderType {
    var senderId: String
    var displayName: String
    var photoUrl: String
}

class ChatViewControllerViewModel {
    
}