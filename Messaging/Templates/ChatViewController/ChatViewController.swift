//
//  ChatViewController.swift
//  Messaging
//
//  Created by Lourdes on 4/26/21.
//

import UIKit
import MessageKit

class ChatViewController: MessagesViewController {
    static let kIdentifier = "ChatViewController"
    
    private var messages = [Message]()
    
    //Mark :- Mock Data
    private let selfSender = Sender(senderId: "1", displayName: "Me", photoUrl: "")
    private let otherSender = Sender(senderId: "2", displayName: "Friend", photoUrl: "")
    private func getDummyMessages() -> [Message] {
        var messagesArray = [Message]()
        messagesArray.append(Message(sender: selfSender, messageId: "1", sentDate: Date(), kind: .text("Hi, This is a message I sent")))
        messagesArray.append(Message(sender: otherSender, messageId: "2", sentDate: Date(), kind: .text("This is a message sent by my friend")))
        return messagesArray
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        messages.append(contentsOf: getDummyMessages())
        initialSetup()
    }
    
    fileprivate func initialSetup() {
        setupDataSourceDelegate()
    }
    
    fileprivate func setupDataSourceDelegate() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
}

extension ChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}

extension ChatViewController: MessagesLayoutDelegate {
    
}

extension ChatViewController: MessagesDisplayDelegate {
    
}
