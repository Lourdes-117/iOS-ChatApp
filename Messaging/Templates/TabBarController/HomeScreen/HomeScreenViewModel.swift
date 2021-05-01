//
//  HomeScreenViewMode.swift
//  Messaging
//
//  Created by Lourdes on 4/27/21.
//

import Foundation

struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}

class HomeScreenViewModel {
    let screenTitle = "Chats"
}
