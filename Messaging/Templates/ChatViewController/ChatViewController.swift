//
//  ChatViewController.swift
//  Messaging
//
//  Created by Lourdes on 4/26/21.
//

import UIKit
import FirebaseAuth
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController {
    static let kIdentifier = "ChatViewController"
    
    let viewModel = ChatViewControllerViewModel()
    
    private var messages = [Message]()
    
    //MARK:- Mock Data
    private let otherSender = Sender(senderId: "2", displayName: "Friend", photoUrl: "")
    private func getDummyMessages() -> [Message] {
        var messagesArray = [Message]()
        messagesArray.append(Message(sender: otherSender, messageId: "1", sentDate: Date(), kind: .text("Hi, This is a message I sent")))
        messagesArray.append(Message(sender: otherSender, messageId: "2", sentDate: Date(), kind: .text("This is a message sent by my friend")))
        return messagesArray
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initialSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    
    func setupConversation(name: String, email: String, isNewConversation: Bool, conversationID: String?) {
        title = name
        viewModel.receiverName = name
        viewModel.receiverEmail = email
        viewModel.isNewConversation = isNewConversation
        viewModel.conversationID = conversationID
        listenForMessage()
    }
    
    fileprivate func initialSetup() {
        setupDataSourceDelegate()
    }
    
    fileprivate func listenForMessage() {
        guard let conversationID = viewModel.conversationID else { return }
        DatabaseManager.shared.getAllMessagesForConversation(with: conversationID) { [weak self] result in
            switch result {
            case .success(let messages):
                guard !messages.isEmpty else {
                    return
                }
                self?.messages = messages
                DispatchQueue.main.async { [weak self] in
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                }
            case .failure(let error):
            debugPrint("Failed To Fetch messages \(error)")
            }
        }
    }
    
    fileprivate func setupDataSourceDelegate() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
}

extension ChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        guard let selfSender = viewModel.selfSender else {
            signOutUserAndForceCloseApp()
            return Sender(senderId: "", displayName: "", photoUrl: "")
        }
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


extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let messageId = viewModel.generateMessageID(),
              let selfSender = viewModel.selfSender else {
            signOutUserAndForceCloseApp()
            return
        }
        if viewModel.isNewConversation {
            //Create Convo in DB
            let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(text))
            DatabaseManager.shared.createNewConversation(with: viewModel.receiverEmail, messageToSend : message, otherUserName: viewModel.receiverName) { success in
                if success {
                    debugPrint("Message Sent")
                } else {
                    debugPrint("Failed To Send")
                }
            }
        } else {
            //Append Convo In DB
        }
    }
}
